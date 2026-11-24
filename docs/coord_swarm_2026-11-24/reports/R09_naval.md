---
owner: R9
decision: D-22
date: 2026-11-24
scope: donor naval feature family vs Godot skirmish port wiring
mode: READ-ONLY; donor inspected via os.walk + open(...,'rb')/latin-1; no donor binary copied or executed
---

# R9 — Naval family recon (donor → port)

## A. Donor inventory (counts by extension; text vs binary)

| Area | Extension / count | Readability |
|---|---|---|
| `data\actors\units` 7 core ship families (yacht, yachttur, fishboat, frigate, galley, battleship, xebec) | `.osm` 49, `.oss` 5 = **54** | binary, struct-parseable (not text); matches `NAVAL_EVIDENCE.md` §2.1 |
| same, extended naval (add chaika 7 `.osm`, ferry 8 `.osm` + 1 `.oss`, ferry_collider) | `.osm` 64, `.oss` 6 = **70** | binary |
| `data\actors\units\attach` naval/ship parts | `.actor` 46 (text), `.osm` 72 / `.oss` 28 (binary) = 146 | mixed |
| `data\animations\aaf` naval incl. balloon/chaika/ferry | `.aaf` **30** (text); ship-only subset **24** (evidence §2.4) | text (`AAF\r\n4\r\n...`) |
| `data\animations\acl` naval incl. balloon | `.acl` **12** (text); ship-only subset **9** (evidence §2.5) | text (`section.begin`) |
| `data\objects\buildings` shipyard/port (`*por.prop`) | `.prop` **5**: `eurpor`, `porpor`, `ruspor`, `turpor`, `ukrpor` | text |
| `data\actors\buildings\**\*por*` shipyard actors | `.actor` 5 + `.osm` ~40 (base/dir/death/attach) | mixed |
| `data\scripts\lib\*.script` (gameplay) | `unit.script` 560 KB, `country.script` 355 KB, `player.script` 145 KB, `weapon.script`, `misc.script` etc. | text |
| `data\scripts\misc\ballon.aix` + `ballon.inc\*` (7) | `.aix` 1 + `.inc` 7 | text |

Binary proof: `yacht.osm` header `49445032...` (IDP2), `yacht.oss` first longs `(311,30,20,584,947,793)`; both non-printable — parseable, never copied. `.aaf/.acl/.actor/.prop/.script/.txt` are 100% printable latin-1.

Donor ship class/upkeep/stop facts (all text): `en\units.txt:777-828` names/classes; `:801-802` galley gold upkeep + "When out of gold, the galley stops firing"; `:815` battleship "Requires a lot gold"; `:827` xebec "Requires no gold"; `:838-839` cannon stop rule; `:974-978` Shipyard "Builds ships"/fish. `unit.script:1874-1896` yacht hp 31000/consume gold 50 + `bturnoff`; `:1922-1958` galley consume 1000 (dual cannon/mortar); `:1959-1997` frigate 150, xebec 0; `:1998-2011` battleship 15000; `:2033-2049` ferry transport 120; `:8185` `bturnoff and gold<4 → cantshootnogold`; `:11657-11743` sail/flag/paddle children. `country.script:3101-3111` port produces all ships, gated by `art` + enable flags. Balloon: `player.script:1910-1925` (upgrade → `bballoon` + FOW + create balloon object), `:2640-2658` map option; `misc.script:5085-5154` `_misc_CreateBalloon`; `ballon.aix` + 7 `.inc`; `balloon.osm` 3.37 MB, `balloon.aaf` 98 B, `balloon.acl` 2851 B.

## B. Claim table

Verdicts: `observed` = literal read; `derived` = counted/cross-checked; `inferred` = judgement.

|#|claim|evidence (donor path:line / port path:line + literal)|method|verdict|action|
|---|---|---|---|---|---|
|1|54 core naval meshes readable; 5 animated `.oss`|donor `docs\NAVAL_EVIDENCE.md:26-57`; `data\actors\units\*.osm/.oss`; port `app\tools\bake_naval.py:46-54` `NAVAL={yacht,yachttur,fishboat,frigate,galley,battleship,xebec}`|os.walk count + struct header|observed / **CONFIRMED**|keep; note extended scope is 70 meshes (chaika/ferry extra)|
|2|24 naval `.aaf` + 9 `.acl` is scoped, not total|donor `data\animations\aaf` 30 / `acl` 12 naval-inclusive; `NAVAL_EVIDENCE.md:68-86`|filename regex + line read|derived / **CONFIRMED (scope)**|quote as "7-family subset" to avoid undercount|
|3|Only 1 naval unit sid live; 5 baked families staged-unwired|port `data.gd:1040-1049` `"yacht"` only; `data.gd:1105` `"trains":["yacht"]`; `index.json:2,53,104,155,206` 5 keys; grep of `app/scripts` found no other ship sid|grep + JSON read|observed / **CONFIRMED (gap)**|TOP-1: add sids + dock trains|
|4|`anim/naval/index.json` path is stale; real path `naval_units/index.json`|port `world.gd:180`, `t_naval.gd:22`, `bake_naval.py:318`; docs `STATUS_GRAPHICS.md:68,130`, `NAVAL_PORT_PLAN.md:34`, `SWARM_BOARD.md:663` ("anim/naval/index.json", "54/1 keys")|filesystem check + doc grep|observed / **CONFIRMED (stale docs)**|update docs to `assets/models/anim/naval_units`; current keys 5, not 1|
|5|2 hull sheets orphaned (no index key) → yacht fallback|port `common/naval/battleship_hull.png`, `xebec_hull.png` exist; `index.json` keys only 5; `world.gd:3097-3100` falls back to `yacht` when info empty|dir listing + index read|derived / **CONFIRMED (gap)**|add hull-only index entries|
|6|Naval render + sim actually wired (not staged)|port `world.gd:159-185` `naval_index`, `:3070-3116` `_hull_tex`/`_draw_naval_hull`, `:3156` call; `game.gd:474` `_is_naval`, `:162-167` water-as-road, `:4219` naval repath, `:3696` spawn|code read + tests `results/t_naval.json:35 passed=true`|observed / **CONFIRMED**|no change; extend tests to 7 families|
|7|Donor gold-shortage ship-stop rule absent in port|donor `units.txt:802` "When out of gold, the galley stops firing"; `unit.script:8185` `bturnoff` + gold<4; port `game.gd:4039-4055` only sets `gold_famine_t`, drains morale after 60 s; no firing gate found|grep `cantshootnogold|bturnoff|gold` in port|derived / **MISSING**|TOP-2: add firing gate|
|8|Port fuel/iron per-shot cost gate also absent|donor `unit.script:1882-1883` iron4/coal9; port `data.gd:1044-1045` declares `cost`, grep for `weapon.cost|EnoughRes` in `game.gd` = 0|grep|derived / **MISSING**|pair with T6-M02|
|9|Upkeep numbers not donor-faithful|donor `unit.script:1890` yacht gold **50**, `:1946` galley 1000, `:1975` frigate 150, `:2008` battleship 15000, `:1996` xebec **0**; port `data.gd:1043` yacht `"eat":{"gold":40}`; hp 900 vs donor 31000 (`:1041` vs `:1874`)|literal compare|observed / **PARTIAL**|align `eat`; keep hp as declared estimate|
|10|Shipyard prerequisite + water adjacency not enforced|donor `country.script:3104-3111` yacht/ferry/… gated by `art` and `enablefrigate`/`enablebattleship`; `units.txt:975`; port `game.gd:3651-3650` gates only `bar18`/`multicannon`; `can_place:3597-3639` no dock-water rule; `_naval_spawn_pos:3703` can return `(-1,-1)`|code compare|derived / **MISSING**|TOP-3|
|11|Balloon is NOT "UI only" in donor; port has no balloon entity|donor `balloon.actor/.osm/.aaf/.acl`, `ballon.aix`+7 `.inc`, `player.script:1910-1925`; port `config.gd:447`, `menu.gd:697-699`, `main.gd:288` mode only, but `game.gd:3435-3436` `reveal_map` IS wired; docs `DONOR_OPTIONS_GAPS.md:37` "UI only … no balloon unit/visibility system"|inventory + code read|derived / **PARTIAL (doc stale)**|TOP-5: correct doc; decide visual|
|12|Xebec no-gold-upkeep rule unsupported|donor `units.txt:827`, `unit.script:1996 consume gold := 0`; port has no xebec sid|literal compare|observed / **MISSING**|fold into TOP-1|
|13|Cannon ships / dual armament reduced|donor `unit.script:1930-1941` galley cannon+mortar; `:1882-1884` yacht flank cannon; port `data.gd:1044-1045` single `cannonball` weapon, no `bshotleftflank` equivalent|literal compare|derived / **PARTIAL**|data-only extension or accept reduced fidelity|
|14|Bake pipeline is live and correct for 5 families|port `bake_naval.py:84-108` `read_osm_hull`, `:165-244` crew `.oss`→8-dir, `:247-298` static hull, `:315-320` `common/naval` + `naval_units`; `index.json` metrics `ortho 6.047/11.355`|file read + results JSON|observed / **CONFIRMED**|no change|
|15|`P-10 IN_PROGRESS`, `FP-1/FP-2 DONE`, `T6-U90 DONE` are consistent with code but overstate completeness|docs `SWARM_BOARD.md:51,120-121,663`; code has yacht-only sid and 6 unwired baked families|board vs grep|inferred / **PARTIAL**|narrow P-10 acceptance to yacht OR extend sids|
|16|`t_naval` green is real but narrow|port `t_naval.gd:22-24` OWNER `"yacht"`; `results/t_naval.json:34-35` `passed:true` 6 checks; no test for other 4 keys or 2 orphans|test read|observed / **PARTIAL**|extend parameterised over index keys|

## C. Top-5 ranked actionable gaps

1. **Wire the other naval sids** — target `app/scripts/data.gd` (`UNITS_BASE` ~1037-1049; `BUILDINGS_BASE.dock.trains` 1105). Minimal change: add `galley/frigate/fishboat/yachttur/battleship/xebec` (+`xebec` eat-gold 0, `battleship` high upkeep) from `unit.script:1873-2049`; keep `naval:true`. Acceptance: dock trains ≥7 sids; each spawns on water and renders its own hull in a deterministic seed dump. Determinism risk: **low** (data-only; spawn ring scan `game.gd:3697-3702` is fixed-order).
2. **Gold-shortage firing stop** — target `app/scripts/game.gd` `_tick_upkeep` ~4039-4055 + attack path; `data.gd` add `bturnoff:true` to naval defs. Minimal change: when `p.res[gold] <= 0`, suppress naval attacks and emit existing "cannot fire" message (donor `unit.script:8185`, `units.txt:802/839`) instead of 60 s morale drain alone. Acceptance: gold=0 → no naval shot; gold restored → firing resumes; no RNG consumed while gated. Determinism risk: **medium** (combat outcomes change only in shortage states; must avoid RNG drift).
3. **Dock prerequisites/placement** — target `app/scripts/game.gd` `can_place` 3567-3639, `place_building` 3641-3650, `train_unit` 3705-3721. Minimal change: require at least one water tile in `_naval_spawn_pos` ring for `dock`; gate advanced ships on finished `art` (donor `country.script:3104-3111`). Acceptance: inland dock placement rejected; no `(-1,-1)` ship spawn; frigate/battleship require arsenal. Determinism risk: **low-medium** (legality change alters build queues on affected maps; verify byte-identical baseline on current seeds).
4. **Orphaned hulls + stale paths** — target `app/assets/models/anim/naval_units/index.json` and docs (`STATUS_GRAPHICS.md:68,130`, `NAVAL_PORT_PLAN.md:34`, `SWARM_BOARD.md:663`), plus `app/tests/t_naval.gd`. Minimal change: add hull-only entries for `battleship`, `xebec` using `bake_naval.py:247-298` metrics; parameterise test over all index keys. Acceptance: 7 keys ↔ 12 referenced PNGs, 0 orphans, 0 fallbacks; docs name `naval_units/`. Determinism risk: **none** (assets/docs only).
5. **Balloon fidelity decision** — target `docs/DONOR_OPTIONS_GAPS.md:37` + `app/scripts/game.gd` upgrade path 3435-3436. Minimal change: correct doc to "option + FOW reveal live; visual entity absent"; if fidelity wanted, spawn a non-colliding balloon child on `aca_balloon1` (donor `player.script:1924-1925`, `misc.script:5085-5154`). Acceptance: doc no longer claims no visibility system; either visual present or explicitly waived. Determinism risk: **low** if visual-only (reveal_map already deterministic).

## D. Open questions

- Are 70 (not 54) meshes the intended recon scope — should chaika/ferry be added to `bake_naval.py:NAVAL`? Ferry has `.oss` + transport-120 behaviour (`unit.script:2043`).
- Does the port want donor hp/price/upkeep verbatim (31000 hp, gold 50/1000/150/0/15000) or keep declared estimates? Current code mixes both.
- Should `bturnoff` apply to all gold-upkeep units (donor yacht/frigate/battleship/chaika, not galley per script) or to galley too per locale text?
- Confirm whether `FP-1/FP-2 DONE` intentionally accepted yacht-only naval scope; if so, close P-10 as YOLO rather than leave IN_PROGRESS.
- Donor `battleship`/`xebec` have static `.osm` hulls only; is hull-only render acceptable as a ship entity, or must a crew `.oss` be synthesised?
