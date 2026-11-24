---
owner: R8
decision: D-22
date: 2026-11-24
scope: donor roster / nations / nation-unique units / upgrade tree (skirmish) vs Godot port
mode: READ-ONLY. Donor inspected via Python open(...,'rb') + latin-1; no donor binary run or copied. No Godot. One output file only.
cross_refs: docs/research/RA_ROSTER.md, docs/audit/MICRO.md, docs/SWARM_BOARD.md, docs/coord_swarm_2026-11-24/reports/R09_naval.md
---

# R8 — Roster / nations / unique units / upgrade tree recon

## 0. Executive finding

The port is **much further along** than `RA_ROSTER.md` and `SWARM_BOARD.md` P-24
describe: **21 nations (incl. `sco`), 48 sim units, 19 buildings (incl. `dock`),
71 upgrades, 1524 building sprite keys with 18 `sco_*` keys**. Those older docs
(20 nations / 50 upgrades / 1506 keys / "ZERO `sco_*` keys") are **stale**, not
current defects.

The real remaining gaps are **depth, not presence**: Scotland has only **1 of 8**
donor-unique combat units and **3 of 13** skinned building families; the naval family
has **1 of 8** sim sids (R9 owns that family); and the upgrade tree, though
71 rows deep, contains **wrong exact values** for firepower tiers, wheellock,
paper cartridge and bayonet, **mis-assigns Mathematics**, and omits all naval
upgrades plus several distinct donor rows. `t_roster_scotland` 6/6 PASS is
**real but weak** — it accepts 3 "sco-ish" unit keys and wrongly counts the
generic `highlander` as Scottish.

## 1. Claim table

Verdicts: `observed` = literal line read; `derived` = count/cross-check;
`inferred` = judgement. Status = CONFIRMED / PARTIAL / MISSING / UNVERIFIED
(/ CONTRADICTED for stale claims).

|#|claim|evidence — donor `C:\Games\Cossacks 3` + port (path:line + literal)|method|verdict|action|
|---|---|---|---|---|---|
|1|Donor has 21 playable nations including Scotland; port now has all 21|D `data\locale\en\units.txt:39-40` `@sco` / `Scotland` (block `:3-46` = 21 nations + `mis` "Originals"); D `data\scripts\lib\country.script:942` `_sco : member := 'pikemansco'`; P `app\scripts\data.gd:227-239` `const NATIONS := { … "sco": {"name": "Scotland"}, }`|literal read + count 21|observed / **CONFIRMED**|Flag `RA_ROSTER.md:181` ("20 nations … no `sco`") and `SWARM_BOARD.md:70` note as STALE; no code gap.|
|2|Scotland has 8 donor-unique combat units (+ `peasco`); port has 2 sco-ish sim keys| D `country.script:942,1039,1143,1266,1573,1936,2031,2820` (`pikemansco`, `musketeersco`, `officersco`, `swordsmansco`, `lancersco`, `raidersco`, `archersco`, `framegun`) + `units.txt:1231` `@peasco`, `:1238` `Covenanter pikeman`, `:1242` `Covenanter musketeer`, `:1249` `Sword Clansman`, `:1254` `Bow Clansman`, `:1261` `Officer`, `:1266` `Lancer`, `:1273` `Raider`, `:1280` `Frame gun`; P `data.gd:243-254` `"sco": {"drummer": "bagpiper", "musketeer": "sco_highlandersword", "serdiuk": "sco_highlandersword"}`; P `data.gd:1007-1018` only `sco_highlandersword`, `:1028-1036` `bagpiper`|literal + count|derived / **PARTIAL (overclaimed DONE)**|Bake+wire 7 missing sco units (`pikemansco`, `musketeersco`, `officersco`, `lancersco`, `raidersco`, `archersco`, `framegun`) and extend NATION_UNITS pike/officer/cossack/cannon slots.|
|3|`t_roster_scotland` 6/6 PASS is genuine but the roster assertion is far below donor spec|P `app\tests\t_roster_scotland.gd:123-125` `check("sco_unique_units_in_roster", sco_unit_keys.size() >= 3, …)`; `:35` `_SCO_TOKENS := ["sco","highland","clan","covenanter","framegun","bagpipe"]`; P `app\tests\results\t_roster_scotland.json:14` `"sco-specific Data.UNITS keys=3 (want >= 3): [\"bagpiper\", \"highlander\", \"sco_highlandersword\"]"`|test + result read|observed / **CONFIRMED PASS, PARTIAL COVERAGE**|Strengthen to assert the 8 donor sco sids explicitly and remove `highland` token (generic Austro-Hungarian unit, not Scottish); see `t_roster_scotland.gd:8-10` stale "feature is PENDING" comment.|
|4|Scotland building art landed — but only 3 of 13 families, not "all"|P `app\assets\models\anim\buildings\buildings.json` = **1524 keys / 21 nation prefixes**; `sco_` keys = **18** = `sco_cen`, `sco_hou`, `sco_bar` × {base,s1..s4,dead}; D `units.txt:1286-1289` `@scoba2` / `Castle` / `Builds highlanders.` (18c barracks) ; P `world.gd:593-603` `_bld_key()` returns `sco_<sid>` **only if that PNG exists**, else bare `sid`|JSON count + code read|derived / **PARTIAL**|P-41's "18 sco_* sheets" is literally true but equals 3 families; `sco_bar18` (Castle) and the other 10 families still use generic art.|
|5|STALE: P-24 "buildings.json has ZERO `sco_*` keys (1506 keys, 20 prefixes)"|P `SWARM_BOARD.md:70` literal `ZERO \`sco_*\` keys (1506 keys, 20 prefixes)`; P actual `buildings.json` 1524 keys / 21 prefixes / 18 `sco_*`; also `RA_ROSTER.md:184` "1506"|doc vs filesystem|observed / **CONTRADICTED (stale)**|Update P-24 and RA_ROSTER counts; keep the historical note that P-41 superseded P-24.|
|6|P-23 "upgrade depth DONE" is real at the plumbing level|P `game.gd:3379-3473` `apply_upgrade()` handles `damage_mult, gather_mult, prot_bonus, unlock18c, field_cap, build_mult, bld_hp_add, fort_hp_add, art_range, art_hp, art_acc, reveal_deposits, reveal_map, unlock_multi, rof_mult, cost_mult, melee_add, cav_dmg_add, cav_prot_bonus, train_speed_mult, art_cost_mult, art_build_mult, heal_all, repair_arty`; P `data.gd:1111-1242` **71** rows (not 50)|code read + count|observed / **CONFIRMED (plumbing) / PARTIAL (fidelity)**|Keep; narrow P-23's acceptance wording to "71 rows with value mismatches listed below".|
|7|Firepower tier values differ from donor|D `upgrades.txt:28,30,32,34` `aca.12 +10%`, `aca.13 +10%`, `aca.14 +15%`, `aca.15 +25%`; P `data.gd:1200-1207` `aca_fire1 1.1`, `aca_fire2 1.15`, `aca_fire3 1.2`, `aca_fire4 1.3`|literal compare|observed / **PARTIAL (3 of 4 wrong)**|Set multipliers to 1.1 / 1.1 / 1.15 / 1.25; keep names/costs unless separately verified.|
|8|Wheellock & paper cartridge RoF over-stated vs donor|D `country.script:3664` `upgplace+'.31' … gc_upg_type_attpauseperc, -30`; `:3697` `'.33' … attpauseperc, -30`; D `upgrades.txt:66,70` `rate of fire +30%`; P `data.gd:1208-1211` `aca_rof1/2 "…(+35% RoF)" effect rof_mult 0.65` (=×1.54, i.e. +54%)|script numeric + literal compare|observed / **PARTIAL (wrong value and wrong label)**|Use `rof_mult ≈ 0.769` (1/1.30) and rename to +30% for both rows.|
|9|Bayonet +5 in donor, +7 in port (stale dmscript comment says +7)|D `country.script:3705,3707` `'.35' … gc_upg_type_damage, 5 … gc_obj_weapon_kind_pike`; D `upgrades.txt:74` `(cold steel weapons +5)`; D `dmscript.global:542` `gc_ai_upg_baginet = 35; // … +7` (stale comment); P `data.gd:1214-1215` `bla_bayonet1 … melee_add 7`|script numeric vs locale vs comment|observed / **PARTIAL (donor-internal conflict, script wins)**|Change to `melee_add: 5`; record the dmscript-global comment as stale in MECHANICS.md.|
|10|Steel grades: +25% 18c melee present, +2 cuirass defence missing as a distinct row|D `country.script:3702` `'.34' … gc_upg_type_shield, 2`; `:3709` `'.36' … damageperc, 25`; D `upgrades.txt:72,76`; P `data.gd:1216-1217` `bla_steel1 … damage_mult sword/pike 1.25` only; P `data.gd:1114-1115` `bla_armor1 prot_bonus 2` is generic, not armoured-only|script numeric + compare|derived / **PARTIAL**|Add an `aca_steelcuirass` row with `prot_bonus 2` gated to armoured units (or document the generic mapping as an accepted approximation).|
|11|Harness/mounted recruitment: -33% (locale) vs ×2 (script comment) vs port ×2|D `upgrades.txt:134` `(mounted units recruitment speed -33%)`; D `dmscript.global:546` `gc_ai_upg_horse = 39; // … в 2 раза`; P `data.gd:1218-1219` `bla_harness1 … train_speed_mult 0.5`|literal compare|observed / **UNVERIFIED (donor value conflict)**|Resolve from `country.script` upgrade params before changing; do not silently flip.|
|12|Mathematics is mis-typed: donor accuracy +35%, port artillery range +10%|D `country.script:3629` `'.27' … gc_upg_type_attdispertionperc, -35`; D `upgrades.txt:58` `(artillery accuracy +35%)`; P `data.gd:1160-1161` `"art_range2" … "effect":{"art_range":1.1}, "name":"Mathematics (range +10%)"`|script numeric + literal compare|observed / **MISSING (wrong effect)**|Change Mathematics to `art_acc: 0.65`; move the +10% range to the donor's unicorn/carronade row (`aca.17`).|
|13|Medical science heal-all is fully wired|D `upgrades.txt:55-56` `@%nat%aca.26` / `Develop medical science … (heals all live units)`; D `country.script:3627` `'.26' … gc_upg_type_healing, 50`; P `data.gd:1234-1235` `"aca_med1" … {"heal_all":true}`; P `game.gd:3465-3468` `if eff.has("heal_all"): … hu.hp = hu.max_hp`|literal + code read|observed / **CONFIRMED**|No change.|
|14|Field upgrades exact values match|D `upgrades.txt:8` `aca.4 … (field capacity +200%)`; `:130` `bla.1 … (field capacity +100%)`; P `data.gd:1134-1137` `aca_field1 field_cap 3.0`, `bla_field1 field_cap 2.0`; applied `game.gd:3404-3409`|literal compare|observed / **CONFIRMED**|No change.|
|15|Mine capacity ladder matches donor 95-peasant cap|D `units.txt:940` `The maximum number of peasants working at a single mine with all the upgrades is 95.`; `upgrades.txt:79-90` `+5,+8,+10,+12,+15,+40`; P `data.gd:1091-1096` base `slots:5`; `:1180-1197` `mine_*_up2..7` slots 5,8,10,12,15,40|derived (5+40=95 base+upgrades)|derived / **CONFIRMED**|No change; port has one extra `mine_*_up1` +50% multiplier tier not in donor (minor).|
|16|Grain storage +180% (not +250%) matches donor|D `upgrades.txt:144` `Improve grain crops storage … (harvesting +180%)`; P `data.gd:1130-1133` `mil_food2 … gather_mult food 2.8` name `Grain storage +180%`|literal compare|observed / **CONFIRMED**|No change; `RA_ROSTER.md` era note corroborated.|
|17|All ~7 naval upgrade rows absent from the port| D `upgrades.txt:10` `aca.5 boat efficiency +100%`; `:12` `aca.6 frigate building`; `:18` `aca.7 fishing boat cost -85%`; `:60` `aca.28 ship speed +40%`; `:62` `aca.29 battleship construction`; `:64` `aca.30 shipbuilding speed x10`; `:165-166` `@%com%por.1` / `repair all ships`; D `country.script:3993` `gc_upg_type_healing, 50` for `por.1`; P `data.gd:1111-1242` 71 rows contain no ship/rigging/hull/fishing/boat upgrade|grep + literal|derived / **MISSING**|Add 7 rows; effects can be data-only flags until R9's naval sim expands (cross-ref `R09_naval.md` §C).|
|18|Stone excavation +200% tier missing|D `country.script:3615` `'.24' … gc_upg_type_effectstoneperc, 200`; D `upgrades.txt:52` `(stone excavation efficiency +200%)`; P `data.gd:1146-1147` only `aca_stone1 … 2.0` (+100%)|literal compare|derived / **MISSING**|Add `aca_stone2` `gather_mult.stone = 3.0` using the donor cost tuple at `country.script:3615` (column meanings not yet verified).|
|19|Agriculturists' salary +50% has no port row|D `upgrades.txt:6` `aca.3 Raise agriculturists' salary … harvesting +50%`; P `data.gd:1118-1119` `aca_bread1` is +25% food ("Crop rotation"), no +50% salary row|grep + literal|derived / **MISSING**|Add a distinct +50% food-gather row (or map `aca_bread1` to 1.5 and rename).|
|20|Ships repair (`por.1`) absent; artillery repair present| D `upgrades.txt:165-166`, `country.script:3993` `por.1 … healing,50`; P `data.gd:1240-1241` `art_repair1 {"repair_arty":true}`, no `ship_repair` row; `game.gd:3469-3472` handles only artillery|grep + literal|derived / **MISSING**|Add `por_repair1` effect `repair_ships` and a `game.gd` handler mirroring `repair_arty`.|
|21|Cathedral / Mosque / Orthodox Cathedral building absent from sim and sprites|D `units.txt:927-930` `@%nat%tem` / `Cathedral` / `Builds priests.`; `:1065-1072` `turtem/algtem=Mosque`, `rustem/ukrtem=Orthodox Cathedral`; P `data.gd:1053-1106` `BUILDINGS_BASE` 19 keys (no `tem`); `buildings.json` 13 families/nation (aca,art,bar,bar18,bla,cen,dip,hou,mar,mil,sta,sto,tow) — no `tem`|count + literal|derived / **MISSING**|Add `tem` + `BUILDINGS_BASE` trains priest and bake `tem` sprites; `priest` already exists (`data.gd:686-694`).|
|22|Palisade / wood gate families absent as art; only procedural walls| D `units.txt:1003-1015` `@%com%wga` `Gate`, `@%com%wwa` `Palisade`, `Ranged units can fire through the palisade.`; P `data.gd:1087-1090` procedural `wal`/`gat` only; no `wwa`/`wga` keys in `buildings.json`|literal + count|derived / **PARTIAL (behaviour, no art)**|Bake `wwa`/`wga`; keep `wal`/`gat` sims as the generic backing.|
|23|Naval roster is 1/8 sim sids, 5 baked families; render falls back to yacht|D `units.txt:777-828` `fishboat/Boat`, `yacht/Yacht`, `galley/Galley`, `frigate/Frigate`, `battleship/Ship of the Line`, `ferry/Ferry`, `xebec/Xebec`, `:789` `yachttur`; P `data.gd:1040-1049` only `"yacht"`; `naval_units/index.json` 5 keys `{yacht,yachttur,fishboat,frigate,galley}`; `world.gd:3093-3100` `key = "yacht"` fallback|JSON + literal read|derived / **PARTIAL**|Owned by R9 — see `R09_naval.md` claim 3 and Top-5 #1; do not duplicate tickets here.|
|24|Baked-but-unwired sprite sets still exist outside Scotland|P `land_units/index.json` 54 keys incl. 8 national peasants + `bagpiper,cossackdon,cossackregister,hackapell`; P `UNITS_BASE` 48 rows cover all 54 except the 8 national peasants (which resolve visually via `world.gd:444-455` `_anim_key`); `sco_units.json` 1 key wired via `data.gd:258-271` EXTRA_ANIM_INDEX|set compare|derived / **CONFIRMED (mostly resolved)**|RA G08 is largely landed for sim units; keep visual-only national peasants as-is.|

## 2. Concisely missing roster / upgrade items (donor evidence)

**Scottish units (7)** — donor `country.script:942,1039,1143,1573,1936,2031,2820` +
`units.txt:1238,1242,1261,1254,1266,1273,1280`: `pikemansco` (Covenanter pikeman),
`musketeersco` (Covenanter musketeer), `officersco` (Officer), `archersco` (Bow Clansman),
`lancersco` (Lancer), `raidersco` (Raider), `framegun` (Frame gun). Port has only
`sco_highlandersword` + `bagpiper` (`data.gd:253,1007,1028`).

**Scottish buildings (10+)** — donor `scoba2` = Castle (`units.txt:1286-1289`) for the
18c barracks; port `buildings.json` has `sco_cen/sco_hou/sco_bar` only.

**Other named units** — donor-localised types still with no sim row: `coselete`
(`units.txt:1327`), `gauduk`/Hajduk (`:1321`), `pandurhun`/Szekely (`:1354`),
`jagerpor`/Volunteer (`:1340`), `guardcavalrysax` (`:1225`), `sipahi`/Heavy Sipahi
(`:1311`), `kingmusketeer`, `jaeger`, `mounted jaeger`, `pospolite ruszenie`,
`commander`. Port folds these into 48 generic sim types (a deliberate reduction —
`RA_ROSTER.md §6` — so triage only if per-nation fidelity is required).

**Buildings** — Cathedral/Mosque (`units.txt:927-930,1065-1072`), Shipyard art
(`:974-978`, port has sim `dock` only), Palisade/wood gate art (`:1003-1015`).

**Upgrades** — naval set (7 rows, §1 #17), stone +200% (`:3615`), agriculturists'
+50% (`:6`), cuirass defence +2 (`:3702`), ship repair (`:3993`); plus value
corrections for firepower tiers, wheellock, paper cartridge, bayonet and Mathematics.

## 3. Top-5 ranked actionable gaps

1. **Value-fidelity pass on the existing upgrade table** — target `app/scripts/data.gd`
   (`UPGRADES_BASE` 1111-1242). Minimal change: 4 literal edits (`aca_fire2/3/4` to
   1.1/1.15/1.25; `aca_rof1/2` to ≈0.769 + "+30%"; `bla_bayonet1` to 5;
   `art_range2` → `art_acc 0.65`), add `aca_steelcuirass` prot_bonus 2.
   Acceptance: each port effect equals the donor script numeric at
   `country.script:3664,3697,3705,3709,3629,3702`. Determinism risk: **medium** —
   changes combat RNG consumption; re-run all 29/29 selftests and byte-identical dumps.

2. **Add the 7 missing Scottish unique units** — target `app/scripts/data.gd`
   (`UNITS_BASE` + `NATION_UNITS.sco`, 253/1007-1036) plus new sheets under
   `app/assets/models/anim/sco/units/` and one `sco_units.json` key each. Minimal
   change: copy the `sco_highlandersword` stat/sprite pattern; wire generic sids
   `pikeman→pikemansco`, `archer→archersco`, `officer→officersco`,
   `cossack→lancersco/raidersco`, `cannon→framegun`. Acceptance: all 8 donor-unique
   sco unit rows + `bagpiper` present and spawnable; strengthen
   `t_roster_scotland.gd:123` to count the 8 donor sids explicitly.
   Determinism risk: **low** if sprite-only additions; **medium** if NATION_UNITS
   changes alter AI army picks (verify current seed dumps unchanged or re-baseline).

3. **Bake `sco_bar18` (Castle) + the remaining 10 sco building families** — target
   `app/assets/models/anim/buildings/buildings.json` and the `sco/buildings` bake
   pipeline (`app/tools/bake_scottish.py:52` already has `UNIT_KEY`; add a building
   pass). Acceptance: `buildings.json` sco prefix count ≥ 78 (13 families × 6),
   `world.gd:593-603` `_bld_key` returns `sco_*` for every sco building.
   Determinism risk: **none** (assets only).

4. **Add the naval upgrade rows + ship repair** — target `app/scripts/data.gd`
   `UPGRADES_BASE` and `app/scripts/gd` effect handler `game.gd:3379-3473`.
   Minimal change: 7 data rows with data-only flags (`ship_speed`, `unlock_frigate`,
   `boat_cost_mult`, `unlock_battleship`, `shipbuild_speed`, `repair_ships`);
   implement `repair_ships` mirroring `repair_arty`. Acceptance: rows exist and
   `apply_upgrade()` does not no-op them. Determinism risk: **low** (flags inert
   until R9's naval sim work lands).

5. **Correct stale claims in three docs/tests** — target `docs/SWARM_BOARD.md:69-71`,
   `docs/research/RA_ROSTER.md:181,184,188`, `app/tests/t_roster_scotland.gd:8-10,123`.
   Minimal change: 21 nations / 71 upgrades / 1524 keys / 18 `sco_*` sheets;
   P-23 "71 rows, value fidelity partial"; P-41 "3 families, 1 unique unit";
   remove "feature is PENDING" comment. Acceptance: no doc claims a count below
   the measured values. Determinism risk: **none**.

## 4. Open questions

- **Donor-internal conflicts**: `dmscript.global:542` bayonet +7 vs `country.script:3707`
  damage 5; `dmscript.global:546` harness ×2 vs `upgrades.txt:134` -33%;
  `upgrades.txt:40` Gribovalle +50% vs `dmscript.global:525` +150% (port chose +150%).
  Which source is authoritative for skirmish? Recommend `country.script` numeric params,
  with locale `.txt` as tooltip copy.
- Is the generic `highlander` (`data.gd:931-939`) intentionally counted as Scottish by
  `t_roster_scotland`? It is an Austrian/Hungarian 18c unit in the donor (`units.txt:421-422`).
- Should the port keep folding ~15 nation-unique named units into generic sim types,
  or add 1:1 rows? Effort is data+art; no gameplay blocker identified.
- Are the 18 `sco_*` sheets intended as a deliberate 3-family subset, or an
  interrupted bake? `bake_scottish.py` currently handles only the unit key.
- No `buildings.txt` exists in `data\locale\en`; building names live in the BUILDINGS
  section of `units.txt:895-1015`. The task's `buildings.txt` reference should be
  corrected in the swarm brief.
- The full-donor-tree string scan launched as a background shell produced no output
  during this pass; all donor facts above come from directly opened, targeted files.
