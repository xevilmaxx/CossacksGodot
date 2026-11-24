---
owner: W2-2
decision: D-22
date: 2026-11-24
gap: G-W2, G-RO2 (plus G-N1 W2-10 data.gd hand-off)
title: "Data-table truth pass: grapeshot range, upgrade values, naval + Scotland rows"
scope: app/scripts/data.gd ONLY + this report; donor read via Python open(...,'rb')/latin-1, never executed or copied
mode: verified-in-current-source before edit; one targeted runner test, no full selftest
status: FIXED (targeted t_upgrades 6/6 PASS)
cross_refs: reports/R04_combat_weapons.md, reports/R08_roster_upgrades.md, reports/R09_naval.md, reports/W210_naval_assets.md, GAPS.md
---

# W2-2 — data.gd truth pass

## 0. Method and pre-edit verification

Every claim below was re-verified against the **current** `app/scripts/data.gd`
before editing (mindset: DONE is UNDONE until re-found). Report line numbers from
R04/R08 are stale in places: R08 cited `data.gd:1200-1207` for the firepower
tiers; the pre-edit literals were actually at **1204-1211** (drift +4). All
donor reads were `open(path,'rb').read().decode('latin-1')`, read-only. Donor
`unit.script` lives at `C:\Games\Cossacks 3\data\scripts\lib\unit.script`
(the R04/R08 shorthand `unit.script` omits `lib\`).

Backup before edit: `Copy-Item app\scripts\data.gd inbox\backup\data.gd.bak-W22`
(69,576 bytes, 2026-11-24 09:00:50).

Diff size after all edits: `git diff --stat -- app/scripts/data.gd` →
`1 file changed, 248 insertions(+), 10 deletions(-)`.

## 1. Item verdict table

Legend: **VERIFIED-ALREADY** = re-checked, no change needed · **FIXED** = mismatch
confirmed and corrected · **NOT-DONE** = real gap left deliberately (reason given).

| # | Item | Donor evidence (path:line, literal) | Port pre-edit (path:line) | Verdict | Exact change (post-edit line) |
|---|---|---|---|---|---|
| 1 | Cannon grapeshot range | `data\scripts\lib\unit.script:1710` `SetObjBaseWeapon(...,1, 0, 350{1200}..., 0, 450, 0, 550, gc_obj_weapon_kind_cannister, True)` → radiusmax **450 px**, detectmax 550 px | `data.gd:659` `"max": 175 * PX_TO_M` | **FIXED** | `175 * PX_TO_M` → `450 * PX_TO_M` (`data.gd:665`). Conversion documented in-place: `PX_TO_M := 1/26.6666666` (header line 16, `data.gd:22`), so 450 px = 16.875 m; old 175 px = 6.5625 m. Only range changed; cd/cost left as declared estimates (donor pause 350, iron 24, coal 21). |
| 1b | Howitzer invented cannister | `unit.script:1732-1763` defines **only** weapon[0] cannonball (R04 claim 8) | `data.gd:725-726` cannister row | **NOT-DONE** (documented) | Added a 4-line comment at `data.gd:729-732` marking the row a PORT-ONLY extension, not donor parity. Row kept to avoid a behaviour change (R04 GAP-2 is a separate ticket). |
| 2a | Firepower tier 1 | `locale\en\upgrades.txt:28` aca.12 `fire power +10%`; `country.script:3555` `damageperc, 10` | `data.gd:1204-1205` `1.1`, `"Rifled barrels +10%"` | **VERIFIED-ALREADY** | untouched. |
| 2b | Firepower tier 2 | `upgrades.txt:30` aca.13 `+10%`; `country.script:3557` `10` | `data.gd:1206-1207` `1.15` / `+15%` | **FIXED** | `1.15`→`1.1`; name `Granular powder +15%`→`+10%` (`data.gd:1406-1407`). |
| 2c | Firepower tier 3 | `upgrades.txt:32` aca.14 `+15%`; `country.script:3559` `15` | `data.gd:1208-1209` `1.2` / `+20%` | **FIXED** | `1.2`→`1.15`; name `Purified sulphur +20%`→`+15%` (`data.gd:1408-1409`). |
| 2d | Firepower tier 4 | `upgrades.txt:34` aca.15 `+25%`; `country.script:3561` `25` | `data.gd:1210-1211` `1.3` / `+30%` | **FIXED** | `1.3`→`1.25`; name `Saltpetre +30%`→`+25%` (`data.gd:1410-1411`). |
| 3 | Wheellock / paper-cartridge RoF | `country.script:3664,3697` aca.31/33 `gc_upg_type_attpauseperc, -30`; **`player.script:1857`** `pause := pause*(1+value/100)` = ×0.70. `upgrades.txt:66,70` tooltip `rate of fire +30%` | `data.gd:1212-1215` `rof_mult 0.65`, names `(+35% RoF)` | **FIXED** | `0.65`→`0.7` for both rows (exact donor script coefficient; port `game.gd:4855` multiplies cooldown by `rof_mult`). Names → `(+30% RoF)` per tooltip. Conflict documented in-place; see Open Q1. |
| 4 | Bayonet melee | `country.script:3705,3707` aca.35 `gc_upg_type_damage, 5` on `gc_obj_weapon_kind_pike`; `upgrades.txt:74` `(cold steel weapons +5)`. `dmscript.global:542` `+7` is a stale comment | `data.gd:1218-1219` `melee_add: 7`, `+7 melee` | **FIXED** | `melee_add: 7`→`5`; name `Bayonets +7 melee`→`+5 melee` (`data.gd:1428-1429`). |
| 5 | Mathematics mis-typed as range | `country.script:3629` aca.27 `gc_upg_type_attdispertionperc, -35`; `upgrades.txt:58` `(artillery accuracy +35%)` | `data.gd:1164-1165` `art_range2` → `{"art_range":1.1}`, `Mathematics (range +10%)` | **FIXED** | `art_range2` effect → `{"art_acc":0.65}`, name → `Mathematics (accuracy +35%)`. Key `art_range2` deliberately retained (no called-symbol rename). The displaced +10 % range is donor aca.17 (`country.script:3575` `attrangeperc, 10`; `upgrades.txt:38` `unicorn, carronade`) and was added as a separate row `aca_range2` with `art_range:1.1`. `art_range1` +5 % (aca.16, `country.script:3564`) was **VERIFIED-ALREADY**, untouched. |
| 6 | Naval upgrades (7 absent) | `upgrades.txt:10,12,18,60,62,64,165-166`; `country.script:3495` `fishingperc,100`; `:3503` `enableunit` (frigate); `:3512-3513` `priceperc` wood `-85`; `:3639` `speedperc,40`; `:3650` `enableunit` (battleship); `:3655` `buildtimeperc,-5000000`; `:3993` `healing,50` | full read of `data.gd:1111-1246`: zero naval/ship rows | **FIXED** | 7 rows appended to `UPGRADES_BASE` (`data.gd:1456-1480`): `aca_boat_eff1` ×2.0, `aca_frigate1` unlock, `aca_fishboat_cost1` ×0.15, `aca_ship_speed1` ×1.4, `aca_battleship1` unlock, `aca_shipbuild1` ×0.1, `por_repair1` repair flag. All effect keys are **inert** (none in `game.gd:3387-3472` handled-key list) — data-only, cannot mislead gameplay; costs/times estimated and marked. |
| 7 | Scotland unique units (7 absent) | names/mapping `units.txt:1237-1284`; `country.script:942,1039,1143,1266,1573,1936,2031,2820`; stats `unit.script:630-636,735-754,771-787+852-859,997-1039,1062-1074,1418-1430+1524-1531,1320-1329+1392-1398,1823-1840` | `data.gd:1007` `sco_highlandersword` + `:1028` `bagpiper` only | **FIXED** (data-only) | **8** `UNITS_BASE` rows added (`data.gd:1047-1142`): `pikemansco`, `swordsmansco`, `musketeersco`, `archersco`, `officersco`, `lancersco`, `raidersco`, `framegun` — all 8 literal donor combat sids. R08 §2 wrote "7" because it counted the pre-existing port stand-in `sco_highlandersword` as `swordsmansco`; I added the literal donor sid too (donor `units.txt:1248-1252`, `unit.script:735-754` sco override at `:746-753`). `sco_highlandersword` remains untouched. Donor-exact hp/price/prot/weapon damage+range; speed/score/aiforce/build_time/icon flagged ESTIMATED in comments. No `NATION_UNITS`/train wiring, no sprite keys: unreachable in current play; assets belong to W2-10. |
| 8 | G-N1 W2-10 hand-off: 6 ship sids + dock trains | `reports/W210_naval_assets.md` §3.1/§3.2; donor `unit.script:1856-2008` (hp/price/upkeep/weapons) | only `yacht` (`data.gd:1040-1049`); `dock.trains == ["yacht"]` (old `:1105`) | **FIXED** (integrated) | 6 rows added (`fishboat`, `yachttur`, `galley`, `frigate`, `xebec`, `battleship`, `data.gd:1156-1237`) and `dock.trains` extended to all 7 sids (`data.gd:1294`). Donor-exact fields from W2-10 §3.1 retained; every estimated field keeps W2-10's flag. AI never builds docks (`ai.gd` grep: no `dock`/`naval`), so no AI seed-trace change. |

Counts re-found by scripted key count (backup vs current): UNITS_BASE **48 → 62**
(+8 Scotland +6 W2-10 ships); UPGRADES_BASE **72 → 80** (+7 naval +1 `aca_range2`).
R08's "71 upgrades" was one short of the 72 measured in the current pre-edit
source. BUILDINGS_BASE still 19.

## 2. Determinism note

* **No RNG added.** No `rand*`/seeded call was introduced; all changes are static
  table literals plus comments.
* **AI research list untouched.** `ai.gd:534` `order := ["aca_bread1", ...,
  "art_range1", "art_hp1"]` is a hardcoded literal and was not edited. The 7 new
  naval upgrade ids are not in it, so AI research order/cadence is unchanged.
* **AI army picks untouched.** `NATION_UNITS` (`data.gd:243-254`) and every
  `BUILDINGS_BASE.*.trains` list except `dock` were not edited. `dock` is never
  built by AI.
* **Behavioural changes that DO affect seeded combat** (honest disclosure): the
  cannon cannister now reaches 450 px instead of 175 px, and firepower/RoF/bayonet/
  Mathematics values changed. `t_final_gate` / `t_sim_hotspots` golden outcomes
  may shift and need coordinator re-baselining. No full selftest was run (per
  charter); only the single targeted `t_upgrades` job below.
* New Scotland rows are unreachable (no NATION_UNITS wiring, no train lists); new
  naval rows have inert effects. Neither changes current skirmish simulation.

## 3. Verification run

Command (exactly as chartered):

```
python app\tools\godot_runner.py run --id w22-data-truth --timeout 180 -- --headless --path app --script res://tests/t_upgrades.gd
```

Runner job id: **w22-data-truth** → ticket **1265**, waited 183.83 s in queue,
`END ok` (run 29.94 s). Result: **PASS 6/6**, `"passed": true` at
`app/tests/results/t_upgrades.json:34-36`. Per-check details (all `passed: true`):

| check | observed detail (verbatim from result JSON) |
|---|---|
| `firepower_tiers_depth` | `bullet damage_mult tiers with >1x = 6 (need >= 3): ["aca_fire1=1.10", "aca_fire2=1.10", "aca_fire3=1.15", "aca_fire4=1.25", "bla_bullet1=1.20", "sta_fire1=1.15"]` — confirms the corrected tier ladder is live. |
| `firepower_damage_stacks` | `effective bullet damage 1.000 -> 1.210 (want 1.210, 2 tiers applied)` |
| `flintlock_cost_and_rof` | `cost-reduction effects=["bla_flint1"], rof_mult effects=["aca_rof1", "aca_rof2"]` |
| `bayonet_melee_upgrade` | `bayonet=["bla_bayonet1"] steel=["bla_steel1"] melee_add 0->5 melee_mult 1.00->1.00 sword 1.00->1.25` — confirms bayonet is now +5. |
| `cavalry_and_drills` | `cavalry recruit effects=["bla_harness1"], drill effects=["aca_riding1", "sta_fence1", "sta_fire1", "bar_phys1", "bar_music1", "bar_grenade1"]` |
| `no_duplicate_application` | `sword mult 1.250 -> 1.438 -> 1.438, upgrade recorded 1 times` |

Note: the test asserts structure/stacking, not donor exact values beyond what the
details print; the donor-exact numbers are evidenced in §1 and the in-file comments.
No full selftest was run (charter). After the job completed I made one **comment-only**
correction in `data.gd` (the Scotland block header now says 8, not 7, because the
literal `swordsmansco` row was added alongside the existing `sco_highlandersword`
stand-in). No executable literal changed after the test, so the result above still
describes the shipped file.

## 4. Open questions / hand-offs

1. **RoF donor-internal conflict.** `country.script:3664/3697` `-30` pause
   (`player.script:1857` → ×0.70, i.e. ~+42.9 % RoF) vs `upgrades.txt:66,70`
   tooltip "+30 % RoF". D-22 prefers numeric script params, so the effect is
   0.70 and the name follows the tooltip. If the coordinator prefers tooltip
   truth, set `rof_mult` to `1/1.3 ≈ 0.7692308`; no other row depends on it.
2. **Shipbuilding speed conflict.** `country.script:3655` `buildtimeperc,
   -5000000` reads as -50 % (cf. aca.10 `-7500000` = -75 % at `country.script:
   3530`), but `upgrades.txt:64` says "x10". Stored x10 flag, flagged in-place;
   inert until R9 adds a handler.
3. **Ship hp scale conflict (W2-10 §3 inference caveat).** New ship rows use
   donor hp (30,000-90,000) while the pre-existing yacht keeps its declared
   estimate 900 (~34×). Rescaling all seven is a coordinator decision; not done
   here because it would change existing yacht combat/seed traces.
4. **Galley weapon[1]** is donor `mortarball` (`unit.script:1935-1938`); port has
   no such kind. Stored as long-range `cannonball`; true bombard is W2-1/R09 #13.
5. **Xebec `eat.gold = 0`** is donor-exact but `game.gd:4831-4834` gates firing on
   *presence* of a gold upkeep key. W2-1 must arbitrate the gold-firing-stop rule.
6. **Scotland `archersco` firearrow** donor weapon[1] (`unit.script:1005,1034`)
   deliberately NOT added: the port has no `firearrow` weapon and `PROT_SLOT`
   clamps that kind; adding it would introduce a new live weapon kind.
7. **Scotland sprite keys / NATION_UNITS wiring** remain with W2-10 and the
   coordinator; these data rows are intentionally unreachable until then.
8. **t_naval** still tests only `yacht` (`t_naval.gd:22`); W2-10 §4 asks for a
   parameterised 7-key test. Not in my ownership.
9. **No full selftest** was run by design; only the one targeted job in §3.

## 5. Compliance

Donor read via `open(...,'rb')` + latin-1, never executed or copied. Only
`app/scripts/data.gd` and this report were written by me. No godot invocation
outside the one chartered `godot_runner.py` job. No AI research list, RNG, or
called-symbol rename. Backup retained at `inbox/backup/data.gd.bak-W22`.
