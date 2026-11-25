---
id: DUNIT-01
owner: DUNIT-01
task: "Donor unit roster, costs, build times and per-nation uniques for the 3D variant"
date: 2026-11-25
status: DELIVERED
mode: "donor READ-ONLY (Python bytes/latin-1); no donor binary run, no donor copy, no code edit, no Godot run, no runner job; this report is the only file written"
labels: observed | derived | inferred | UNVERIFIED
donor_root: "C:\\Games\\Cossacks 3"
port_evidence: SECONDARY (donor wins on every value conflict)
---

# DUNIT-01 — Donor unit roster, costs, build times and per-nation uniques

## Goal

Give the roster owner a donor-authoritative, `path:line`-cited unit table for the
3D variant: every trainable unit sid, its English name, six-resource cost tuple,
build time, HP, armour, weapon ranges, training building / era gate, and the
17c/18c variants; identify nation-unique units; rank the ones missing or
approximated in `variant3d/scripts/data.gd`; and correct prior-doc errors.
Port facts are **SECONDARY** — where port and donor disagree, the donor value
below is truth and the port delta is recorded as an approximation.

## Sources

### Donor (all READ-ONLY; opened with `python` 3.14 `open(path,'rb').read().decode('latin-1')`)

| Tag | Path (under `C:\Games\Cossacks 3`) | What it supplies |
|---|---|---|
| **U** | `data\scripts\lib\unit.script` | `_unit_InitBase` (`U:457-2647`): the definitive per-sid stat table — `SetObjBasePrice`, `SetObjBaseProtection`, `SetObjBaseWeapon`, `SetObjBaseSearchBuildVisionScore`, `consume`, `usage`. Helper signatures `U:478-581`. Cost escalation `U:5652-5689`. |
| **C** | `data\scripts\lib\country.script` | Per-nation roster (`C:2655-2909`, `_country_AddMember`) and training/requirements (`C:2911-3116`, `_country_AddFixedProduceWithAccessControl`). Access control `C:508-529`. |
| **L** | `data\locale\en\units.txt` | `@sid` → English name (next line). Nations block `L:1-46`. |
| **G** | `data\scripts\dmscript.global` | `gc_frames_to_time = 0.03125`, `gc_time_to_frames = 32`, `gc_buildtime_modifier = 10` (`G:170-182`), food-per-unit etc. (`G:770-815`). |
| **M** | `data\scripts\lib\misc.script` | `_misc_FramesToTime(val) = val*gc_frames_to_time` (`M:470-474`), `_misc_BuildtimeToTime(val) = val*gc_frames_to_time*gc_buildtime_modifier` (`M:478-482`). |
| **A** | `data\objects\units\*.prop`, `data\actors\units\*.oss` | Geometry-only props/meshes (enumerated read-only); **no stat fields**. The task's generic `data\units\**` path does not exist; stats live in U/C. `data\scripts\units\global.inc\*.inc` are network/AI state handlers, not stat definitions. |

### Prior docs read (as instructed)

`docs/research/RA_ROSTER.md`; `docs/coord_swarm_2026-11-24/reports/V763_missing_models.md`;
`V772_import_new_objs.md`; `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md`
(costs/production record at `DEC_02_scripts.md:585-637,654-676`);
`DEC_03_configs.md`; `docs/coord_swarm_2026-11-24/reports/R08_roster_upgrades.md`.

The task's bare `decomp/DEC_02_scripts.md` / `DEC_03_configs.md` resolve to
`docs/coord_swarm_2026-11-25/decomp/` (an older `docs/decomp/` duplicate exists).

### Port (SECONDARY, read-only)

`P:` = `variant3d/scripts/data.gd` — `NATIONS` `P:247-259`, `NATION_UNITS`
`P:263-274`, `UNITS_BASE` `P:597-1262` (**62** unit keys; measured by parsing
top-level `\t"sid": {` lines up to `BUILDINGS_BASE` at `P:1263`), `BUILDINGS_BASE`
`P:1263+`. Model/manifest state corroborated from V7-63/V7-72.

---

## Donor roster table (observed unless noted)

**Column key.** Cost = `F/W/St/G/I/C` in the order `SetObjBasePrice(objbase, food, wood, stone, gold, iron, coal)` (`U:493-501`) — **six** resources, not four. Build = frames in the `SetObjBaseSearchBuildVisionScore` 4th arg (`U:571-581`); seconds = frames × 0.03125 (`M:470-474`). Prot = `pike/sword/bullet/cannister/arrow/cannonball` (`U:510-518`). Weapon = `kind dmg pause minR–maxR` in **donor pixels** (`U:520-546`; `px→tiles = px/53.3333`, `px→metres` uses port `PX_TO_M`). `default` = −1 = inherit base value (`U:593`). `X*32` = X seconds written in frames. Upkeep from `objprop.consume[...]`.

### 6.1 Infantry — 17th century

| sid | L name | Nations (C) | Cost F/W/St/G/I/C (U) | Build fr → s (U) | HP | Prot (U) | Weapon dmg / min–max px (U) | Upkeep / req (U,C) | Cite |
|---|---|---|---|---|---:|---|---|---|---|
| `pikeman` | Pikeman, 17c (L:285) | aus,fra,eng,swe,pru,ven,den,net,bav,sax,hun,pie (C:2680,2685) | 25/0/0/3/20/0 (U:633) | 144 → 4.5 (U:636) | 90 (U:631) | 3/2/4/210/6/40 (U:634) | pike 8 / 35–100 (U:632) | bar + bla (C:3027) | U:630-640 |
| `pikemanpol` | Pikeman, 17c (L:291) | pol (C:2666) | 25/0/0/1/0/0 (U:645) | 96 → 3.0 (U:647) | 90 (U:643) | 0/0/0/0/0/0 (U:646) | pike 8 / 35–110 (U:644) | bar + bla (C:3028) | U:642-648 |
| `pikemantur` | Ottoman Pikeman (L:296) | tur,alg (C:2668-2676) | 55/0/0/5/0/0 (U:652) | 176 → 5.5 (U:654) | 95 (U:650) | 0/0/0/0/0/0 (U:653) | pike 9 / 35–110 (U:651) | bar + bla (C:3029) | U:649-655 |
| `pikemanrus` | **Spearman** (L:302) | rus (C:2667) | 45/0/0/4/15/0 (U:659) | 176 → 5.5 (U:661) | 85 (U:657) | 2/1/4/140/4/25 (U:660) | pike 8 / 45–90 (U:658) | bar + bla (C:3030) | U:656-662 |
| `pikemansco` | Covenanter pikeman (L:1238) | sco (C:2684) | 35/0/0/2/0/0 (U:666) | 128 → 4.0 (U:668) | 100 (U:664) | 0/0/0/0/0/0 (U:667) | pike 9 / 35–100 (U:665) | bar + bla (C:3031) | U:663-669 |
| `pikemanpor` | (inherits Pikeman; L:1361) | por (C:2686) | 40/0/0/4/5/0 (U:687) | 128{144} → 4.0 (U:689) | 100 (U:685) | 0/1/1/25/4/0 (U:688) | pike 9 / 35–100 (U:686) | bar + bla (C:3033) | U:684-690 |
| `pikemanspa` | **Coselete** (L:1327) | spa (C:2908) | 35/0/0/7/30/0 (U:673) | 176 → 5.5 (U:675) | 100 (U:671) | 3/4/6/240/12/50 (U:674) | pike 10 / 35–100 (U:672) | bar + bla (C:3027) | U:670-676 |
| `pikemanswi` | (inherits Pikeman; L:1367) | swi (C:2687) | 40/0/0/6/20/0 (U:680) | 160 → 5.0 (U:682) | 90 (U:678) | 3/3/6/220/6/45 (U:681) | pike 10 / 35–100 (U:679) | bar + bla (C:3034) | U:677-683 |
| `lightinfantry` | Light Infantryman (L:322) | tur,alg (C:2671,2676) | 25/0/0/0/1/0 (U:715) | 32 → 1.0 (U:717) | 55 (U:713) | 0×6 (default) | sword 5 / 15–50 (U:714) | bar (no bla) (C:3036) | U:712-720 |
| `roundshier` | Roundshier (L:329) | aus (C:2681) + generic | 20/0/0/3/25/0 (U:738) | 128 → 4.0 (U:741) | 100 (U:736) | 3/3/7/225/16/80 (U:739) | sword 6 / 25–60 (U:737) | bar + bla (C:3035) | U:735-744 |
| `musketeer` | Musketeer, 17c (L:338) | fra,eng,swe,pru,ven,den,bav,sax,por,pie,swi (C:2700) | 45/0/0/6/5/0 (U:780) | 192 → 6.0 (U:782) | 70 (U:772) | 0×6 (default) | bullet 12 / 400–800, pause 150 fr (U:774) | bar + bla (C:3037) | U:771-785 |
| `musketeeraus` | Musketeer, 17c (L:345) | aus (C:2694) | 35/0/0/9/15/0 (U:918) | 208 → 6.5 (U:920) | 55 (U:916) | 2/2/5/165/5/35 (U:919) | bullet 12 / 400–800, pause 160 (U:917) | bar + bla (C:3038) | U:915-921 |
| `musketeerpol` | Musketeer, 17c (L:359) | pol (C:2692) | 40/0/0/3/3/0 (U:792) | 144 → 4.5 (U:795) | 70 (U:790) | 0×6 | bullet 9 / 300–700, pause 100 (U:791) | bar + bla (C:3039) | U:789-796 |
| `musketeerspa` | Musketeer, 17c (L:367) | spa (C:2695) | 40/0/0/12/20/0 (U:927) | 240 → 7.5 (U:929) | 85 (U:923) | 3/2/5/210/7/40 (U:928) | bullet 15 / 400–850, pause 190 (U:924) | bar + bla (C:3040) | U:922-930 |
| `musketeernet` | Musketeer, 17c (L:352) | net (C:2699) | 50/0/0/8/4/0 (U:803) | 160 → 5.0 (U:802) | 65 (U:798) | 0×6 | bullet 10 / 400–800, pause 120 (U:799) | bar + bla (C:3055) | U:797-804 |
| `strelet` | **Strelets** (L:429) | rus (C:2693) | 70/0/0/7/9/0 (U:936) | 272 → 8.5 (U:937) | 85 (U:932) | 0×6 | bullet 12 / 200–700, pause 150 (U:933) | bar + bla (C:3042) | U:931-940 |
| `serdiuk` | **Serdiuk** (L:445) | ukr (C:2696) | 60/0/0/11/5/0 (U:839) | 352 → 11.0 (U:840) | 85 (U:834) | 0×6 | bullet 12 / 400–900, pause 130 (U:836); ammo iron 3 / coal 6 (U:837-838) | bar (no bla) (C:3043) | U:833-842 |
| `jannisary` | **Janissary** (L:454) | tur (C:2697) | 55/0/0/13/5/0 (U:848) | 256 → 8.0 (U:849) | 65 (U:844) | 0×6 | bullet 12 / 400–850, pause 150 (U:845); ammo iron 3 / coal 5 (U:846-847) | bar + bla (C:3044) | U:843-852 |
| `gauduk` | **Hajduk** (L:1321) | hun (C:2702) | 35/0/0/4/4/0 (U:864) | 144 → 4.5 (U:867) | 60 (U:862) | 0×6 | bullet 9 / 300–750, pause 100 (U:863) | bar + bla (C:3045) | U:861-868 |
| `archer` | Archer (L:463) | alg (C:2698); also `archertur`, `archersco` overrides | 20/2/0/1/0/0 (U:1013) | 48 → 1.5 (U:1015) | 40 (U:998) | 0×6 | arrow 15 / 400–700, pause 75 (U:999); firearrow 150 / 400–600 (U:1005) | bar (no bla) (C:3046) | U:997-1020 |
| `archertur` | **Turkish archer** (L:1132) | tur (C:2898) | 45/3/0/4/0/0 (U:1026) | 96 → 3.0 (U:1027) | 65 (U:1022) | 0×6 | arrow 20 / 300–900, pause 85 (U:1023); firearrow 150 / 450–900 (U:1025) | bar + bla (C:3056) | U:1021-1028 |
| `archersco` | **Bow Clansman** (L:1254) | sco (C:2704) | 0/0/0/15/0/0 (U:1048) | 40 → 1.25 (U:1050) | 20 (U:1043) | 0×6 | arrow 25 / 350–700, pause 80 (U:1044); firearrow 100 / 300–750 (U:1046); upkeep food×1.33 (U:1038), gold 16 (U:1054) | ba2 + bla (C:3086) | U:1029-1061 |

### 6.2 Infantry — 18th century

| sid | L name | Nations (C) | Cost (U) | Build fr → s | HP | Prot | Weapon (U) | Upkeep / req | Cite |
|---|---|---|---|---|---:|---|---|---|---|
| `pikeman18` | Pikeman, 18c (L:308) | 16 nations (C:2690); **not** ukr/tur/alg/sco (C:2832) | 30/0/0/2/0/0 (U:696) | 40 → 1.25 (U:698) | 85 (U:694) | 0×6 | pike 9 / 45–100 (U:695) | ba2 (C:3063) | U:693-702 |
| `pikeman18swe` | Pikeman, 18c (L:315) | swe (C:2689) | 40/0/0/3/0/0 (U:707) | 48 → 1.5 (U:708) | 110 (U:705) | 0×6 | pike 11 / 35–100 (U:706) | ba2 (C:3064) | U:704-711 |
| `musketeer18` | Musketeer, 18c (L:376) | 13 nations (C:2707) | 50/0/0/40/40/0 (U:952) | 144 → 4.5 (U:954) | 100 (U:942) | 0×6 | pike 10 / 35–65 (U:943) + bullet 16 / 400–900, pause 150 (U:946) | ba2 + bla (C:3071) | U:941-960 |
| `musketeer18pru` | Musketeer, 18c (L:383) | pru (C:2708) | 70/0/0/80{200;240}/40/0 (U:966) | 192 → 6.0 (U:967) | 100 (base) | 0×6 | pike 10 / 35–85 + bullet 22{55}, pause 150 (U:962-963) | ba2 + bla (C:3072) | U:961-968 |
| `musketeer18bav` | (inherits; L:1209) | bav (C:2710) | 60/0/0/55{35;160}/35{45}/0 (U:974) | 160{225;180} → 5.0 (U:975) | 100 (base) | 0×6 | pike 5 / 35–85 + bullet 22, pause 190 (U:970-971) | ba2 + bla (C:3080) | U:969-976 |
| `musketeer18sax` | Musketeer, 18c (L:390) | sax (C:2711) | 40/0/0/45{35;45}/40{45}/0 (U:983) | 144{225;144} → 4.5 (U:984) | 90 (U:978) | 0×6 | pike 7 + bullet 19, pause 140 (U:979-980) | ba2 + bla (C:3081) | U:977-985 |
| `musketeer18den` | (inherits; L:1179) | den (C:2709) | 50/0/0/80/40/0 (U:992) | 176{150;225;192} → 5.5 (U:993) | 100 (U:987) | 0×6 | pike 8 / 35–85 + bullet 29{60;40}, pause 190 (U:988-989) | ba2 + bla (C:3077) | U:986-996 |
| `pandur` | Pandur (L:438) | aus (C:2713) | 40/0/0/15/10/0 (U:810) | 176 → 5.5 (U:811) | 85 (U:806) | 0×6 | bullet 17 / 400–900, pause 150 (U:807) | ba2 + bla (C:3065) | U:805-813 |
| `chasseur` | Chasseur (L:415) | fra (C:2714) | 50/0/0/45/15/0 (U:819) | 240 → 7.5 (U:820) | 75 (U:815) | 0×6 | bullet 20 / 500–1050, pause 190 (U:816) | ba2 + bla (C:3066) | U:814-822 |
| `highlander` | Highlander (L:422) | **eng** (C:2715) — see Correction C4 | 90/0/0/25/10/0 (U:828) | 208 → 6.5 (U:829) | 130 (U:824) | 0×6 | bullet 16 / 300–850, pause 160 (U:825); food×1.33 (U:831) | ba2 + bla (C:3067) | U:823-832 |
| `jagerpor` | **Volunteer** (L:1340) | por (C:2716) | 30/0/0/2/5/0 (U:883) | 72 → 2.25 (U:884) | 50 (U:879) | 0×6 | bullet 10 / 400–800, pause 190 (U:880) | ba2 + bla (C:3068) | U:878-886 |
| `jagerswi` | **Jaeger** (L:1373) | swi (C:2717) | 40/0/0/70/20/0 (U:892) | 272 → 8.5 (U:893) | 65 (U:888) | 0×6 | bullet 20 / 500–1200, pause 220 (U:889) | ba2 + bla (C:3069) | U:887-896 |
| `pandurhun` | **Szekely** (L:1354) | hun (C:2718) | 30/0/0/25/10/0 (U:874) | 208 → 6.5 (U:875) | 75 (U:870) | 0×6 | bullet 19 / 400–1000, pause 160 (U:871) | ba2 + bla (C:3070) | U:869-877 |
| `grenadier` | Grenadier (L:397) | 13 nations (C:2720); not pru | 80/0/0/60/40/0 (U:1241) | 192{150;180} → 6.0 (U:1243) | 120 (U:1227) | 0×6 | pike 18 / 25–80 + bullet 16 / 400–900 + mortarball 110 / 200–500 (U:1228-1235); food×1.2 (U:1248) | ba2 + bla (C:3073) | U:1226-1249 |
| `grenadierden` | (inherits; L:1186) | den (C:2721) | 100/0/0/90/40/0 (U:1257) | 208{150;180}{c1 135} → 6.5 (U:1258) | 125 (U:1251) | 0×6 | pike 22 / 25–80 + bullet 19 / 450–900 (U:1252-1253) | ba2 + bla (C:3078) | U:1250-1259 |
| `grenadierpru` | (inherits; L:1201) | pru (C:2907) | 90/0/0/100/45/0 (U:1265) | 224 → 7.0 (U:1266) | 125 (U:1261) | 0×6 | pike 18 + bullet 16, pause 140 (U:1262-1263) | ba2 + bla (C:3079) | U:1260-1267 |
| `grenadierbav` | (inherits; L:1216) | bav (C:2722) | 95/0/0/70/40/0 (U:1275) | 192{150;180} → 6.0 (U:1276) | 125 (U:1269) | 0×6 | pike 14 + bullet 19 / 300–900 (U:1270-1271) | ba2 + bla (C:3082) | U:1268-1277 |
| `grenadiersax` | Grenadier (L:405) | sax (C:2723) | 50/0/0/60/40/0 (U:1285) | 192{135;150} → 6.0 (U:1287) | 100 (U:1279) | 0×6 | pike 22 + bullet 19, pause 140 (U:1280-1281); food×1.0 (U:1286) | ba2 + bla (C:3083) | U:1278-1288 |
| `grenadierhun` | (merc; L:1346) | hun (C:2724) | 0/0/0/25/0/0 (U:1308) | 48 → 1.5 (U:1309) | 30 (U:1302) | 0×6 | pike 30 + bullet 16 + mortarball 200 (U:1291-1307); upkeep gold 60 (U:1313) | ba2 + bla (C:3084) | U:1289-1319 |
| `swordsmansco` | **Sword Clansman** (L:1249) | sco (C:2705) | 110/5/0/10/0/0 (U:749) | 224 → 7.0 (U:752) | 180 (U:747) | 1/2/2/110/6/10 (U:750) | sword 10 / 25–60 (U:751); food×1.5 (U:753) | ba2 + bla (C:3087) | U:746-755 |
| `musketeersco` | Covenanter musketeer (L:1242) | sco (C:2701) | 55/0/0/8/7/0 (U:857) | 224 → 7.0 (U:858) | 90 (U:853) | 0×6 | bullet 12 / 350–850, pause 150 (U:854) | bar + bla (C:3041) | U:852-860 |
| `officersco` | Officer (L:1261) | sco (C:2729) | 130/0/0/130/10/0 (U:1093) | 320 → 10.0 (U:1095) | 150 (U:1091) | 0×6 | pike 40 / 35–65 (U:1092); gold 70 (U:1096) | bar + aca (C:3054) | U:1090-1099 |
| `framegun` | **Frame gun** (L:1280) | sco (C:2820) | 0/200/0/300/150/0 (U:1837) | 1600 → 50.0 (U:1839) | 3000 (U:1824) | 0×6 | cannonball 500 / 200–1800, pause 90 (U:1830); gold 300 (U:1840) | art + bla (C:3098) | U:1823-1854 |

### 6.3 Fast cavalry (usage `fasthorse`, U:1329)

| sid | L name | Nations (C) | Cost (U) | Build fr → s | HP | Weapon (U) | Upkeep / req | Cite |
|---|---|---|---|---|---:|---|---|---|
| `croat` | Croat (L:577) | aus (C:2749) | 80/0/0/6/2/0 (U:1334) | 504 → 15.75 (U:1335) | 240 (U:1332) | sword 9 / 25–65 (U:1333); food×2 (U:1337) | sta + bla (C:2975) | U:1331-1338 |
| `hussar` | Hussar (L:584) | 14 nations (C:2754), **18c gate** (C:2983) | 70/0/0/20/2/0 (U:1349) | 480{528;475;570} → 15.0 (U:1350) | 200 (base U:1321) | sword 12 / 25–65 (U:1348); food×2 (U:1352) | sta + bla + century18 (C:2983) | U:1347-1353 |
| `hussarpru` | Hussar (L:591) | pru (C:2752), 18c (C:2984) | 80/0/0/15/2/0 (U:1357) | 360{384;325;420} → 11.25 (U:1358) | 210 (U:1355) | sword 9 (U:1356); food×2 (U:1360) | sta + bla + century18 | U:1354-1361 |
| `hussarhun` | (inherits Hussar; L:1333) | hun (C:2751), 17c | 100/0/0/30/2/0 (U:1403) | 672 → 21.0 (U:1404) | 225 (U:1401) | sword 10 (U:1402); food×2 (U:1406) | sta + bla (C:2995) | U:1400-1407 |
| `hussarswi` | **Mounted Jaeger** (L:1379) | swi (C:2753), 18c (C:2996) | 120/0/0/30/2/0 (U:1411) | 624{384;325;420} → 19.5 (U:1412) | 240 (U:1409) | sword 14 (U:1410); food×2 (U:1414) | sta + bla + century18 | U:1408-1415 |
| `wingedhussar` | **Winged Hussar** (L:598) | pol (C:2748) | 130/0/0/30/25/0 (U:1365) | 832{1250} → 26.0 (U:1367) | 225 (U:1363) | pike 14{13} / 20–100 (U:1364); prot 1/2/5/160/10/30 (U:1366); food×2.5 (U:1369) | sta + bla (C:2971) | U:1362-1370 |
| `cossacksich` | **Sich Cossack** (L:607) | ukr (C:2747) | 0/0/0/60/0/0 (U:1382) | 80{50} → 2.5 (U:1383) | 150 (U:1379) | sword 13 / 20–65 (U:1373); merc variant sword 8 (U:1381); food×2 (U:1376), gold 150 (U:1386) | sta (no bla) (C:2972) | U:1371-1391 |
| `croat`(base family) | — | — | 75/0/0/2/5/0 (U:1325) | 528 → 16.5 (U:1327) | 200 (U:1321) | pike 9 / 25–65 (U:1324) | family base | U:1320-1330 |
| `hackapell` | **Hakkapeliitta** (L:1194) | swe (C:2906) | 80/0/0/7/2/0 (U:1342) | 576{960} → 18.0 (U:1343) | 220 (U:1340) | pike 12 (U:1341); food×2 (U:1345) | sta + bla (C:2991) | U:1339-1346 |
| `raidersco` | **Raider** (L:1273) | sco (C:2750) | 130/0/0/8/2/0 (U:1395) | 720 → 22.5 (U:1396) | 280 (U:1393) | sword 11 / 20–65 (U:1394); food×2.5 (U:1398) | sta + bla (C:2993) | U:1392-1399 |

### 6.4 Heavy cavalry (usage `hardhorse`, U:1428)

| sid | L name | Nations (C) | Cost (U) | Build fr → s | HP | Prot (U) | Weapon (U) | Upkeep / req | Cite |
|---|---|---|---|---|---:|---|---|---|---|
| `reiter` | Reiter (L:615) | 14 nations (C:2773) | 120/0/0/10/40/0 (U:1423) | 768 → 24.0 (U:1426) | 300 (U:1419) | 2/6/6/190/15/40 (U:1436) | pike 15 / 20–65 (U:1422); food×2.5 (U:1430) | sta + bla (C:2968) | U:1418-1438 |
| `cuirassier` | Cuirassier (L:621) | 16 nations (C:2775), 18c (C:2982) | 120/0/0/35/25/0 (U:1441) | 720 → 22.5 (U:1443) | 300 (base) | 2/4/10/160/5/80 (U:1442) | pike 14 (U:1440) | sta + bla + century18 | U:1439-1445 |
| `reiterswe` | **Swedish Reiter** (L:636) | swe (C:2757) | 130/0/0/7/20/0 (U:1448) | 720 → 22.5 (U:1450) | 300 (base) | 2/3/7/140/7/35 (U:1449) | pike 14 (U:1447) | sta + bla (C:2969) | U:1446-1452 |
| `reiterpol` | **Light Reiter** (L:642) | pol (C:2758) | 60/0/0/5/2/0 (U:1464) | 264{300} → 8.25 (U:1466) | 190 (U:1462) | 0×6 | sword 9 (U:1463); food×1.5 (U:1468) | sta + bla (C:2976) | U:1461-1469 |
| `guardcavalrysax` | **Cavalry Guard** (L:1226) | sax (C:2759), 18c (C:2992) | 140/0/0/50/20/0 (U:1456) | 768 → 24.0 (U:1458) | 320 (U:1454) | 2/5/9/150/9/70 (U:1457) | pike 15 (U:1455) | sta + bla + century18 | U:1453-1460 |
| `hetman` | **Hetman** (L:649) | ukr (C:2763) | 150/0/0/150/10/0 (U:1473) | 528{432}{450} → 16.5 (U:1475) | 320 (U:1471) | 0/1/3/75/3/15 (U:1474) | pike 70 (U:1472); gold 200 (U:1476), food×3 (U:1478) | sta (no bla) (C:2985) | U:1470-1479 |
| `cossackdon` | **Don Cossack** (L:656) | rus (C:2767) | 100/1/0/0/0/0 (U:1483) | 432{550} → 13.5 (U:1485) | 220 (U:1481) | 0×6 | pike 13 / 30–100 (U:1482); food×2 (U:1487) | sta (no bla) (C:2981) | U:1480-1488 |
| `vityaz` | Vityaz (L:662) | rus (C:2768) | 160/0/0/13/25/0 (U:1492) | 816{1500} → 25.5 (U:1494) | 380 (U:1490) | 2/4/3/160/17/40 (U:1493) | pike 14 / 25–65 (U:1491) | sta + bla (C:2970) | U:1489-1496 |
| `cossackregister` | **Register Cossack** (L:670) | ukr (C:2762) | 70/0/0/15/0/0 (U:1500) | 336 → 10.5 (U:1502) | 250 (U:1498) | 0×6 | pike 12 / 30–100 (U:1499); food×2 (U:1504) | sta + bla (C:2977) | U:1497-1505 |
| `spakh` | **Light Sipahi** (L:677) | tur (C:2770) | 80/0/0/6/5/0 (U:1509) | 288{325} → 9.0 (U:1511) | 230 (U:1507) | 0/1/0/10/2/0 (U:1510) | pike 15 / 30–100 (U:1508); food×2 (U:1513) | sta (no bla) (C:2973) | U:1506-1514 |
| `mameluke` | Mameluke (L:684) | alg (C:2771) | 100/5/0/8/0/0 (U:1518) | 384 → 12.0 (U:1520) | 280 (U:1516) | 1/3/1/75/8/0 (U:1519) | pike 16 / 30–100 (U:1517); food×2 (U:1522) | sta (no bla) (C:2974) | U:1515-1523 |
| `lancersco` | **Lancer** (L:1266) | sco (C:2772) | 120/0/0/6/0/0 (U:1527) | 672 → 21.0 (U:1529) | 320 (U:1525) | 0×6 | pike 11 / 30–100 (U:1526); food×2 (U:1531) | sta + bla (C:2994) | U:1524-1532 |
| `sipahi` | **Heavy Sipahi** (L:1312) | tur (C:2909) | 130/0/0/20/70/0 (U:1536) | 576 → 18.0 (U:1538) | 360 (U:1534) | 3/7/4/225/24/60 (U:1537) | sword 15 (U:1535); food×2.5 (U:1540) | sta + bla (C:2997) | U:1533-1542 |

### 6.5 Ranged cavalry (usage `horseshooter`/`archer`, U:1559/1685)

| sid | L name | Nations (C) | Cost (U) | Build fr → s | HP | Weapon (U) | Upkeep / req | Cite |
|---|---|---|---|---|---:|---|---|---|
| `dragoon` | Dragoon, 17c (L:692) | 14 nations (C:2778) | 90/0/0/7/5/0 (U:1554) | 480{624} → 15.0 (U:1556) | 220 (U:1545) | bullet 15{11} / 300–800, pause 180 (U:1548); food×2 (U:1561) | sta + bla (C:2978) | U:1544-1562 |
| `dragoonpol` | **Pospolite ruszenie** (L:1164) | pol (C:2904) | 70/0/0/5/4/0 (U:1571) | 432 → 13.5 (U:1572) | 185 (U:1567) | bullet 13{12;10} / 400–850, pause 160 (U:1568) | sta + bla (C:2988) | U:1566-1573 |
| `kingmusketeer` | **King's Musketeer** (L:716) | fra (C:2777) | 100/0/0/100/8/0 (U:1579) | 864{960}{2000} → 27.0 (U:1580) | 280 (U:1575) | bullet 43{100} / 200–700, pause 220 (U:1576); gold 150 (U:1581), food×2.5 (U:1584) | sta + bla (C:2979) | U:1574-1585 |
| `dragoon18` | Dragoon, 18c (L:708) | 14 nations (C:2784), 18c (C:2986) | 90/0/0/7/5/0 (base, U:1554) | 480 (base) | 220 (base) | bullet 15 / 300–800 (base) | sta + bla + century18 | U:1544-1562, C:2986 |
| `dragoon18fra` | Dragoon, 18c (L:700) | fra (C:2781), 18c (C:2987) | 50/0/0/30/6/0 (U:1592) | 480 → 15.0 (U:1593) | 140 (U:1587) | bullet 10{7} / 350–800, pause 150 (U:1588); gold 150 (U:1594), food×1.5 (U:1597) | sta + bla + century18 | U:1586-1598 |
| `dragoon18net` | (inherits; L:1171) | net (C:2782), 18c (C:2989) | 100/0/0/70/7/0 (U:1605) | 768{960}{1600} → 24.0 (U:1606) | 320 (U:1600) | bullet 17 / 300–850, pause 160 (U:1601); gold 150 (U:1607), food×2.5 (U:1609) | sta + bla + century18 | U:1599-1610 |
| `dragoon18pie` | (inherits; L:1390) | pie (C:2783), 18c (C:2990) | 60/0/0/65/7/0 (U:1617) | 648{960}{1600} → 20.25 (U:1618) | 200 (U:1612) | bullet 19 / 400–900, pause 160 (U:1613); gold 150 (U:1619), food×2 (U:1621) | sta + bla + century18 | U:1611-1622 |
| `lightcavalry` | Light cavalry (L:1146) | hun (C:2899), 18c (C:2999) | 90/0/0/50/6/0 (U:1629) | 672 → 21.0 (U:1630) | 175 (U:1624) | bullet 14 / 400–1000, pause 170 (U:1625); gold 150 (U:1631), food×2 (U:1633) | sta + bla + century18 | U:1623-1634 |
| `tatar` | **Tatar** (L:725) | tur (C:2779) | 70/2/0/6/0/0 (U:1679) | 360 → 11.25 (U:1681) | 185 (U:1666) | arrow 15 / 500–1100, pause 50 (U:1668); firearrow 140 / 500–1100, pause 150 (U:1673); food×2 (U:1688) | sta (no bla) (C:2980) | U:1665-1690 |

### 6.6 Support / workers / mercenary variants

| sid | L name | Cost (U) | Build fr → s | HP | Notes | Cite |
|---|---|---|---|---|---|---|
| `peasant` (8 nation sids `peaaus/peaeng/peaspa/peapol/pearus/peaukr/peatur/peasco`) | Peasant (L:472); `pearus` = **Serf** (L:489) | 100 food (U:1194) | 400 → 12.5 (U:1196) | 50 (U:1191); ukr 75 (U:1212), sco 60 (U:1217) | sword 20 / 10–65 (U:1193); food 32 (U:1197), rus 26 (U:1209), alg/tur 28 (U:1222); trained at Town Hall (C:2956-2963) | U:1190-1225 |
| `officer` | Officer, 17c (L:505) | 50/0/0/150/30/0 (U:1065) | 320 → 10.0 (U:1068) | 125 (U:1063) | pike 30 / 35–65 (U:1064); prot 2/2/5/200/10/30 (U:1066); gold 60{25} (U:1069). `officerrus`=Commander (L:517): cost 100/0/0/125/5/0 (U:1078), build 400 (U:1081), dmg 40 (U:1080). `officertur` (L:511): 50/0/0/100/0/0 (U:1084), build 240 (U:1087), gold 50 (U:1088). | U:1062-1099 |
| `officer18` | Officer, 18c (L:523) | 50/0/0/200/10/0 (U:1103) | 192{150} → 6.0 (U:1105) | 125 (U:1101) | pike 50 (U:1102); gold 90 (U:1106); ba2 + aca (C:3076) | U:1100-1113 |
| `drummer` (incl. `drummerrus`,`drummertur`,`drummer18`,`bagpiper`) | Drummer 17c/18c (L:529,547), Bagpiper (L:553) | 50/0/0/30/0/0 (U:1134) | 192 → 6.0 (U:1135) | 100 (U:1133); tur 50 (U:1145) | rus cost 90/0/0/15/0/0 (U:1141); tur cost 30/0/0/15/0/0 (U:1146); bar+aca (C:3047-3050) | U:1114-1150 |
| `priest`,`pope`,`mullah`,`padre` | Priest/Pope/Mullah/Padre (L:559,567,571,1386) | 50/0/0/40/0/0 (U:1185) | 800 → 25.0 (U:1186) | 90 (U:1183) | heal weapon radius 400 (U:1154); gold upkeep variants 20/15/40 (U:1163,1178,1187); trained at Temple (`tem`, C:3004-3007) | U:1151-1189 |
| `field` | (field) | — | — | — | usage `gc_obj_usage_field` (U:1693); made at Mill (C:3116) | U:1691-1695 |
| `roundshierdip`, `lightinfantrydip`, `archerdip`, `grenadierdip`, `cossacksichdip`, `dragoon18dip`, `lightcavalrydip`, `archerturdip` | base name + "mercenary" (L:734-770,1139,1154) | merc costs: e.g. roundshierdip 0/0/0/12/0/0 (U:760); lightinfantrydip 0/0/0/4/0/0 (U:725); dragoon18dip 0/0/0/120/0/0 (U:1651) | 48–64 fr | reduced HP | merc flag set `U:612-614`; escalation cap ×2 (`DEC_02_scripts.md:594-596`); trained at Diplomatic Center (C:3012-3022) | U:721-730, 756-769, 1289-1319, 1635-1664; C:3012-3022 |

### 6.7 Artillery and ships

| sid | L name | Cost F/W/St/G/I/C (U) | Build fr → s | HP | Main weapon (U) | Req (C) | Cite |
|---|---|---|---|---:|---|---|---|
| `cannon` | Cannon (L:832) | 0/250/0/400/400/0 (U:1715) | 2400{3840} → 75.0 (U:1717) | 9000 (U:1697) | cannonball 1800 / 550–2160, pause 350 (U:1703); cannister / 0–450 (U:1710); gold 300{500} (U:1718) | art + bla (C:3094) | U:1696-1731 |
| `howitzer` | Howitzer (L:843) | 0/250/0/350/300/0 (U:1746) | 3008{4800} → 94.0 (U:1748) | 3000 (U:1733) | cannonball 4000 / 700–1400{950}, pause 600 (U:1739); gold 350{50} (U:1750) | art + bla (C:3095) | U:1732-1763 |
| `mortar` | Bombard (L:854) | 0/100/0/75/200/0 (U:1779) | 800 → 25.0 (U:1781) | 400 (U:1765) | mortarball 200 / 1250–2600, pause 250 (U:1771); gold 50 (U:1782) | art + bla (C:3096) | U:1764-1793 |
| `multicannon` | Multi-barrelled Cannon (L:866) | 0/200/0/400/250/0 (U:1806) | 1600 → 50.0 (U:1808) | 2000 (U:1795) | cannister 500 / 10–700, pause 60 (U:1800); gold 300 (U:1809) | art + bla, upgrade `enablemulticannon` (C:3097) | U:1794-1822 |
| `framegun` | Frame gun (L:1280) | 0/200/0/300/150/0 (U:1837) | 1600 → 50.0 (U:1839) | 3000 (U:1824) | cannonball 500 / 200–1800, pause 90 (U:1830); gold 300 (U:1840) | sco art (C:3098) | U:1823-1854 |
| `fishboat` | Boat (L:778) | 0/600/0/0/0/0 (U:1862) | 1280 → 40.0 (U:1864) | 300 (U:1856) | none | Port (C:3103) | U:1855-1872 |
| `yacht` / `yachttur` | Yacht (L:782,790) | 0/900/0/450/150/200 (U:1886) | `default{300}` → inherited (comment 300 fr = 9.4 s) (U:1918) | 35000 (U:1905) | cannonball 1000 / 300–1100, pause 350 (U:1880); gold 50 (U:1890) / tur gold 1500 (U:1919) | Port + art (C:3104-3105) | U:1873-1921 |
| `ferry` | Ferry (L:819) | 0/300/0/50/100/0 (U:2040) | 1792 → 56.0 (U:2042) | 62000 (U:2034) | transport (U:2045) | Port + art (C:3106) | U:2033-2054 |
| `galley` | Galley (L:795) | 0/9500/0/900/800/0 (U:1943) | 1600 → 50.0 (U:1945) | 35000 (U:1923) | cannonball 100 / 300–1200 (U:1930); mortarball 1000 / 1100–3100 (U:1935); gold 1000 (U:1946) | Port + art (C:3107) | U:1922-1958 |
| `frigate` | Frigate (L:805) | 0/5000/0/1100/600/800 (U:1972) | 7360 → 230.0 (U:1974) | 50000 (U:1960) | cannonball 1800 / 400–1650, pause 75 (U:1966); gold 150 (U:1975) | Port + art + `enablefrigate` (C:3108) | U:1959-1988 |
| `xebec` | Xebec (L:824) | 0/7000/0/1600/320/960 (U:1994) | (inherits 7360) | 65000 (U:1990) | cannonball / 550–1700, pause 50 (U:1993) | Port + art + `enablefrigate` (C:3110) | U:1989-1997 |
| `battleship` | Ship of the Line (L:811) | 0/9000/0/3200/700/6500 (U:2006) | 12480 → 390.0 (U:2007) | 90000 (U:1999) | cannonball / 600–1950, pause 20 (U:2003); gold 15000 (U:2008) | Port + art + `enablebattleship` (C:3111) | U:1998-2012 |
| `chaika` | (Ukrainian; locale inherits) | 0/1050/0/600/200/400 (U:2022) | 1280 → 40.0 (U:2023) | 25000 (U:2014) | cannonball 1000 / 300–1100, pause 350÷2 (U:2019) | Port + art, ukr only (C:2893-2894,3109) | U:2013-2032 |

**Labels:** all cost/HP/prot/weapon/build values above are **observed** from literal
donor lines; seconds are **derived** (`frames×0.03125`); nation families and
building/era gates are **observed** from `country.script`; population is
**UNVERIFIED** from plaintext donor (see Open Questions).

---

## Cost / build formula (donor-authoritative)

1. **Base price** — `SetObjBasePrice(objbase, food, wood, stone, gold, iron, coal)`
   writes `objbase.price[gc_resource_type_*]` (`U:493-501`). Order is **F/W/St/G/I/C**;
   the port's 4-resource display drops iron/coal, which are also **per-shot ammo**
   costs for shooters (`U:776-777,837-838,846-847`).
2. **Escalation** — `_unit_GetCostByID` (`U:5652-5689`, corroborated
   `DEC_02_scripts.md:587-600`):
   `costmodifier := pow(costpercent/100, countOwned)`;
   `resource_i := floor(base_price[i] * costmodifier)`;
   `costpercent` defaults to 100 (no escalation); mercenaries cap at ×2, others
   at ×20000. Observed non-default `costpercent`: 100.5 (`U:1051,1310,1380`),
   102 (`U:1653`), 105 (`U:1867,1889,2018`). **Derived**: exponential per owned
   unit, not flat.
3. **Affordability** — `_unit_CanApplyCountCostByID` (`U:5694-5717`) multiplies all
   six prices by queue count plus AI buffers (+300 food, +25 gold);
   `DEC_02_scripts.md:602-609` labels the `not`/`>=` precedence **UNVERIFIED**.
4. **Build time (units)** — `SetObjBaseSearchBuildVisionScore(objprop, objbase,
   searchRadius, buildTimeFrames, vision, score)` sets
   `objbase.buildtime := _misc_FramesToTime(buildTimeFrames)`
   (`U:571-581`, `M:470-474`) = `frames × 0.03125 s` = `frames ÷ 32 s`.
   `X*32` literals are X seconds; `default` (−1) means keep the family value.
   Production tick: `deltabuildtime := dt / objbase.buildtime`
   (`DEC_02_scripts.md:654-676`, `units/building.inc/doprogressorders.inc:221`),
   with AI difficulty multipliers 0.30/0.50/0.75/1.00/1.25 (`:222-231`).
5. **Build time (buildings)** — `SetObjBuildingProperties` uses
   `_misc_BuildtimeToTime(val) = val×0.03125×10` (`U:478-483`, `M:478-482`,
   `gc_buildtime_modifier=10` at `G:180`). Do **not** apply ×10 to unit rows.
6. **Upkeep** — `objprop.consume[gc_resource_type_food|gold] := …`, often
   `floor(gc_obj_foodperunit × multiplier)` (e.g. `U:1337`, `U:1369`, `U:1540`).
7. **Training / era gate** — `C:508-529` adds a unit only if both sid and id are
   nation members; `C:2911-3116` encodes `req0/req1/req2` (building prerequisites)
   and `century18` / `enablefrigate` / `enablebattleship` / `enablemulticannon`
   gates. E.g. `pikeman` needs `bar`+`bla` (`C:3027`); `serdiuk` needs only `bar`
   (`C:3043`); `cuirassier`/`hussar`/`dragoon18*` are `century18`-gated
   (`C:2982-2990`); Scottish `ba2` is `scoba2` = Castle.
8. **Population** — **UNVERIFIED**: no per-unit pop field exists in any of the
   222 DScript files (grep of `population` returns only GUI/stat-list plumbing,
   e.g. `lib/player.script:35-38`); the cap is engine-side. The port does not
   model a per-unit pop cost either.

---

## Nation-unique units (donor-wins)

| Nation | Unique combat sids (donor) | 17c / 18c split (C) |
|---|---|---|
| **tur** | `pikemantur` (Ottoman Pikeman), `jannisary`, `archertur`, `spakh` (Light Sipahi), `sipahi` (Heavy Sipahi), `tatar`, `yachttur`, `officertur`, `drummertur`, `mullah`, `lightinfantrydip`/`archerturdip` | no `ba2`/18c barracks (C:2832, C:2833); `sipahi` appended C:2909 |
| **alg** | `pikemantur`, `lightinfantry`, `archer`, `mameluke`, `officertur`, `drummertur`, `mullah`, `xebec` | no 18c |
| **rus** | `pikemanrus` (Spearman), `strelet`, `officerrus` (Commander), `drummerrus`, `pope`, `cossackdon`, `vityaz`, `hetman` | 18c generic only |
| **ukr** | `serdiuk`, `cossacksich`, `cossackregister`, `hetman`, `chaika`, `peaukr`, `ukrwwa`/`ukrwga` | **`no18c`** (C:2832,2893) |
| **pol** | `pikemanpol`, `musketeerpol`, `wingedhussar`, `reiterpol` (Light Reiter), `dragoonpol` (Pospolite ruszenie), `peapol` | 18c generic |
| **swe** | `pikeman18swe`, `reiterswe`, `hackapell`, `peaeng` | 18c-first |
| **pru** | `hussarpru`, `musketeer18pru`, `grenadierpru` | 18c |
| **bav** | `musketeer18bav`, `grenadierbav`, `peaaus` | 18c |
| **sax** | `musketeer18sax`, `grenadiersax`, `guardcavalrysax` | 18c |
| **den** | `musketeer18den`, `grenadierden` | 18c |
| **net** | `musketeernet`, `dragoon18net`, `peaeng` | 18c |
| **fra** | `chasseur`, `kingmusketeer`, `dragoon18fra` | 18c |
| **eng** | **`highlander`** (C:2715), `bagpiper` 18c (C:2738), `peaeng` | 18c |
| **aus** | `musketeeraus`, `roundshier`, `croat`, `pandur`, `peaaus` | 18c |
| **spa** | `musketeerspa`, **`pikemanspa` (Coselete)**, `peaspa` | 18c |
| **por** | **`jagerpor` (Volunteer)**, `pikemanpor`, `peaspa` | 18c |
| **pie** | `dragoon18pie`, `padre`, `peaspa` | 18c |
| **swi** | **`jagerswi` (Jaeger)**, `pikemanswi`, **`hussarswi` (Mounted Jaeger)** | 18c |
| **hun** | **`gauduk` (Hajduk)**, **`pandurhun` (Szekely)**, `hussarhun` (17c), `grenadierhun` (merc), `lightcavalry`, `peapol` | mixed |
| **ven** | generic infantry/cavalry, `peaspa` | 18c |
| **sco** | `peasco`, `pikemansco`, `musketeersco`, `archersco`, `swordsmansco`, `officersco`, `bagpiper`, `raidersco`, `lancersco`, `framegun`, `scoba2` (Castle) | partial 18c (C:3086-3088) |

Bold = highest-value unique names called out in the task. All rows **observed**
from `C:2655-2909` + `L`.

---

## Port parity matrix (SECONDARY evidence — donor wins)

`P:` = `variant3d/scripts/data.gd`. Verdicts: **EXACT** = port price/HP/build/weapon
match the donor family base; **APPROX** = present but values differ; **MISSING** =
no `UNITS_BASE` key; **STAND-IN** = port-only substitute.

| Donor sid (nation) | Port key / line | Stat parity | Notes |
|---|---|---|---|
| `pikeman` | `pikeman` P:607-615 | **EXACT** | 25/3/20, hp90, 144 fr, pike 8 35–100 all match U:631-636 |
| `roundshier` | `roundshier` P:616-624 | **EXACT** | 20/3/25, hp100, 128 fr, sword 6 25–60 match U:736-741 |
| `serdiuk` (ukr) | `serdiuk` P:625-634 | **EXACT** | 60/11/5, hp85, 352 fr, bullet 12 400–900 match U:834-840 |
| `archer` | `archer` P:635-644 | **EXACT** | 20/2/1, hp40, 48 fr, arrow 15 400–800 match U:998-1015 |
| `officer` | `officer` P:664-672 | **EXACT** | 50/150/30, hp125, 320 fr, pike 30 match U:1063-1068 |
| `cannon` | `cannon` P:673-691 | **APPROX** | price/hp/build/ball match; cannister dmg 0→300, cd 350→300, ammo invented (compare U:1710) |
| `peasant` | `peasant` P:598-606 | **APPROX** | hp 75 (donor base 50 U:1191; 75 is the **ukr** override U:1212) |
| `strelet` (rus) | `strelet` P:783-792 | **APPROX** | port 60/11/5, hp?, build 352 — donor 70/7/9, 272 fr (U:932-937) |
| `jannisary` (tur) | `jannisary` P:887-896 | **APPROX** | port 65 food/15 gold/6 iron vs donor 55/13/5 (U:848), bp 380 vs 256 fr (U:849) |
| `sipahi` (tur) | `sipahi` P:878-886 | **APPROX** | port 110 food/40 gold/10 iron vs donor 130/20/70 (U:1536); bp 520 vs 576 fr |
| `spakh` (tur) | `spakh` P:897-905 | **APPROX** | port 100/30/8 vs donor 80/6/5 (U:1509) |
| `tatar` (tur) | `tatar` P:868-877 | **APPROX** | port 80 food/10 wood vs donor 70 food/2 wood/6 gold (U:1679) |
| `wingedhussar` (pol) | `wingedhussar` P:821-829 | **APPROX** | port 130/30/5, bp 480 vs donor 130/30/25, 832 fr (U:1365-1367) |
| `cossack` family (ukr/rus) | `cossack` P:645-653; `cossackdon` P:1019; `cossackregister` P:1049 | **APPROX** | generic 130 food/2 iron vs donor `cossacksich` 60 gold (U:1382); `cossackdon` port 110/25 vs donor 100/1 food/wood (U:1483) |
| `mameluke` (alg) | `mameluke` P:906-914 | **APPROX** | port 105/35/8 vs donor 100/5/8 (U:1518) |
| `vityaz` (rus) | `vityaz` P:915-923 | **APPROX** | port 115/50/15 vs donor 160/13/25 (U:1492) |
| `hetman` (ukr) | `hetman` P:924-932 | **APPROX** | port 120/60/20 vs donor 150/150/10 (U:1473) |
| `croat` (aus) | `croat` P:933-941 | **APPROX** | port 30 food/3 gold vs donor 80 food/6 gold/2 iron (U:1334) |
| `pandur` (aus) | `pandur` P:942-950 | **APPROX** | port 35/5 vs donor 40/15/10 (U:810) |
| `chasseur` (fra) | `chasseur` P:951-960 | **APPROX** | port 55/12/6 vs donor 50/45/15 (U:819) |
| `highlander` (**eng**) | `highlander` P:961-969 | **APPROX + mis-attributed** | port 45/5/10 vs donor 90/25/10 (U:828); R08 calls it Austro-Hungarian (wrong, C4) |
| `gauduk` (hun) | — | **MISSING** | U:861-867, C:2702, L:1321 |
| `pandurhun` (hun) | — | **MISSING** | U:869-875, C:2718, L:1354 |
| `jagerpor` (por) | — | **MISSING** | U:878-884, C:2716, L:1340 |
| `jagerswi` (swi) | — | **MISSING** | U:887-893, C:2717, L:1373 |
| `hussarhun` (hun) | — | **MISSING** | U:1400-1406, C:2751, L:1333 |
| `hussarswi` (swi) | — | **MISSING** | U:1408-1414, C:2753, L:1379 |
| `reiterswe` (swe) | — | **MISSING** | U:1446-1450, C:2757, L:636 |
| `reiterpol` (pol) | — | **MISSING** | U:1461-1468, C:2758, L:642 |
| `guardcavalrysax` (sax) | — | **MISSING** | U:1453-1458, C:2759, L:1226 |
| `kingmusketeer` (fra) | — | **MISSING** | U:1574-1584, C:2777, L:716 |
| `dragoonpol` (pol) | — | **MISSING** | U:1566-1572, C:2904, L:1164 |
| `dragoon18fra/net/pie` | — | **MISSING** | U:1586-1622, C:2781-2783 |
| `pikemanspa` (spa) | — | **MISSING** | U:670-676, C:2908, L:1327 |
| `archertur` (tur) | — | **MISSING** | U:1021-1027, C:2898, L:1132 |
| `cossacksich` (ukr) | — | **MISSING** (generic `cossack` instead) | U:1371-1391, C:2747, L:607 |
| `musketeeraus/pol/spa/net`, `pikemanrus/tur`, `grenadierden/pru/bav/sax` | — | **MISSING** (folded into generic) | U sections above, C:2692-2724 |
| `chaika` (ukr) | — | **MISSING** from UNITS_BASE (mesh exists, V7-63) | U:2013-2032, C:2893-2894 |
| `ferry` | — | **MISSING** | U:2033-2052, C:3106 |
| 8 merc `*dip` variants | — | **MISSING** | U/C/L cited above |
| `pikemansco`,`musketeersco`,`archersco`,`swordsmansco`,`officersco`,`lancersco`,`raidersco`,`framegun`,`bagpiper` | all present P:1058,1081,1091,1101,1115,1126,1136,1146,1156 | **APPROX** (stats estimated; P:1076-1079 admits unreachable) | models landed V7-63/V7-72; donor stats in §6.2/6.4 |
| `sco_highlandersword` | P:1037-1048 | **STAND-IN** | port-only key standing in for `swordsmansco`; comment P:1039 admits estimate |

**Model/manifest parity (SECONDARY, V7-63/V7-72):** 79/81 roster IDs now have
an OBJ; only `bar18` and `dock` are cube fallbacks
(`V763_missing_models.md:97-110,155-160`); 56 new `.import` sidecars landed
(`V772_import_new_objs.md:79-100`). All imported meshes are **static bind poses /
port approximations**, NOT donor-faithful animation (`V763:177-184`).

---

## Ranked missing-units list (for roster owner)

Rank = gameplay impact × uniqueness × ease of wiring. Donor cites first.

| # | Unit | Donor cites | Why it matters |
|---:|---|---|---|
| 1 | `gauduk` (Hajduk, hun) | U:861-867; C:2702; L:1321 | Hungary's 17c shooter; no port key at all |
| 2 | `pandurhun` (Szekely, hun) | U:869-875; C:2718; L:1354 | Hungary's 18c unique shooter; no port key |
| 3 | `jagerpor` (Volunteer, por) + `jagerswi` (Jaeger, swi) | U:878-893; C:2716-2717; L:1340,1373 | two DLC nations' signature skirmishers |
| 4 | `kingmusketeer` (fra) | U:1574-1584; C:2777; L:716 | high-impact 17c mounted skirmisher, dmg 43 |
| 5 | `guardcavalrysax` (sax) + `reiterswe` (swe) + `reiterpol` (pol) | U:1446-1468; C:2757-2759; L:636,642,1226 | three nations' unique heavy cav; port has only generic `reiter` |
| 6 | `pikemanspa` (Coselete, spa) + `archertur` (Turkish archer, tur) | U:670-676,1021-1027; C:2908,2898; L:1327,1132 | two base nations' unique 17c units |
| 7 | `hussarhun` + `hussarswi` + `dragoonpol` | U:1400-1414,1566-1572; C:2751,2753,2904 | missing national cavalry variants |
| 8 | `dragoon18fra/net/pie` | U:1586-1622; C:2781-2783 | three 18c national dragoons folded into one |
| 9 | `sipahi` stat correction (present but wrong) | U:1533-1542; C:2909; P:878-886 | port cost 110/40/10 vs donor 130/20/70; highest-value fidelity fix |
| 10 | `cossacksich` (ukr) | U:1371-1391; C:2747; L:607 | Ukraine's signature 17c cavalry folded into generic |
| 11 | `chaika` + `ferry` ships | U:2013-2052; C:2893-2894,3106 | chaika mesh exists; no sim row |
| 12 | 8 `*dip` mercenaries + national rifle/musketeer skins | U/C as tabled | deliberate reduction — triage only if per-nation fidelity required |

---

## Corrections to prior docs (explicit)

- **C1 — `RA_ROSTER.md:181` "20 nations … no `sco`" is STALE.** Port now has 21
  nations including `sco` (`P:247-259`); already flagged by R08 claim 1. Donor
  has 21 + hidden `mis` (`L:1-46`). **observed**.
- **C2 — `RA_ROSTER.md:186` "42 sim unit types" is STALE.** `UNITS_BASE` now has
  **62** keys (`P:597-1262`, counted by parsing top-level sid rows). R08's "48"
  (`R08:15`) is also stale.
- **C3 — `RA_ROSTER.md:192-195` "baked-but-unwired" list is STALE.**
  `cossackdon`, `hackapell`, `cossackregister`, `bagpiper` are all wired
  (`P:1019,1028,1049,1058`); only the 8 national peasant sprites remain
  visual-only. V7-63/V7-72 then added 56 meshes + imports.
- **C4 — R08 open question / claim "highlander is an Austrian/Hungarian 18c unit
  in the donor (`units.txt:421-422`)" is WRONG.** `L:421-422` merely says
  "Highlander" with no nation; the actual member assignment is
  **`if (eng) then _country_AddMember(..., 'highlander', ...)` at `C:2715`**.
  It is England's 18c unique shooter, not Austria/Hungary's. The port's
  `highlander` may be Scottish by test token, but donor says England.
- **C5 — `RA_ROSTER.md:99-105` treats "Spearman" and "Ottoman Pikeman" as separate
  roster families.** They are the English names of `pikemanrus` (`L:302`) and
  `pikemantur` (`L:296`) — nation skins of the pikeman family, not extra types.
  Likewise `spakh`=Light Sipahi / `sipahi`=Heavy Sipahi (`L:677,1312`).
- **C6 — port `serdiuk` build 352 frames is CORRECT, not an error.** It matches
  donor `U:840`. By contrast `jannisary` (port 380 vs donor 256, `U:849`),
  `sipahi` (520 vs 576, `U:1538`) and `wingedhussar` (480 vs 832, `U:1367`)
  are genuine approximations and should be flagged as such.
- **C7 — `RA_ROSTER.md:139` "Cathedral/Mosque absent" still holds in the sim**
  (`P:1263+` has no `tem`), but note `priest`/`pope`/`mullah`/`padre` units
  already exist (`P:712,970,979,988`); only the training building is missing.
- **C8 — V7-63/V7-72 status is SECONDARY and unchanged:** `bar18`/`dock` still
  lack donor actors; no new donor stat source was found for them
  (`V763:155-164`). Do not invent a mapping.

---

## Open questions

1. **Population per unit** — UNVERIFIED: engine-side; no DScript field. Need a
   live-game or PE-level check before adding a pop cost to the port.
2. **Braced numeric alternatives** — many donor lines use `{a;b;c}` comments
   (e.g. `U:966,975,983,993,1275`). This report takes the **leading** value as
   live truth and treats braces as history, per the code-comment convention;
   confirm with a patched game/data build if exact live values matter.
3. **Donor-internal conflicts** inherited from R08 (`dmscript.global:542` bayonet
   +7 vs `country.script:3707` damage 5; harness ×2 vs −33%): unchanged; script
   numeric params win, locale text is tooltip copy.
4. **`cossacks.exe` / packed archives** — not inspected; any stat table injected
   at runtime by a binary patch would be UNVERIFIED here. All values came from
   the plaintext files above.
5. **Precise px→metre conversion for weapons** — the port uses `PX_TO_M`
   (`P` header line 16); donor only guarantees px→tiles (`U:529-535`,
   `G:170-173`). The roster table deliberately reports raw **donor pixels**.
6. **Mercenary cost escalation cap** — `DEC_02_scripts.md:594-596` derives ×2 for
   mercs from `U:5674-5678`; confirm which `*dip` pairs share a counter
   (`U:5660-5672`) before porting escalation.

---

## Summary

- Donor truth for **~90 trainable unit sids** (17c/18c + national skins + ships +
  mercs) is now extracted with `path:line` citations from `unit.script`,
  `country.script` and `units.txt`; the previous generic `data\units\**`/
  `*.prop` path contains geometry only, not stats.
- Cost formula: six resources `F/W/St/G/I/C`, exponential escalation
  `floor(base × (costpercent/100)^owned)`; unit build time = frames ÷ 32 s
  (buildings use ×10 `gc_buildtime_modifier`).
- The port has **62** `UNITS_BASE` keys and **21** nations; only a handful of
  units (`pikeman`, `roundshier`, `serdiuk`, `archer`, `officer`) are
  stat-exact; most nation uniques are **APPROX** or **MISSING**.
- Top three roster-owner actions: (1) add the 10 missing national unique unit
  sids (`gauduk`, `pandurhun`, `jagerpor`, `jagerswi`, `kingmusketeer`,
  `reiterswe`, `reiterpol`, `guardcavalrysax`, `pikemanspa`, `archertur`);
  (2) correct `sipahi`/`jannisary`/`wingedhussar` costs and build times;
  (3) keep `highlander` attributed to **England**, not Austria/Hungary.
- No donor binary was executed, copied or modified; no code, board or test was
  edited. Only this report was written.
