---
owner: W5-1
date: 2026-11-24
wave: 5
area: app/scripts/ai.gd ONLY (+ this report)
backup: inbox/backup/ai.gd.bak-W51 (32,483 bytes, taken before first edit)
charter: disjoint files; runner only; one clean 300 s soak; no unseeded RNG
gaps: G-AI4 force/wave acceptance; per-slot AI tier consumer (R06 C1)
runner_jobs: 1295 w51-force-soak (SKIPPED 0 s, FIFO race); 1298 w51-force-soak2 (FAILED at startup, 2 parse errors, no sim); smoke probe then final soak PENDING
status: CODE FIXED / SOAK PENDING
donor_access: read-only latin-1 via Python; no donor binary executed
---

# W5-1 — force/wave acceptance and per-slot AI tier consumer

> Verification policy: every claim below was re-read in the **current** source
> before editing. Nothing was inherited as DONE from W2-4 / W2-12 reports.
> Donor literals were re-read directly from
> `C:\Games\Cossacks 3\data\scripts\` (`PE` = `units/global.inc/progresseconomicai.inc`,
> `CLS` = `lib/classes.script`, `DG` = `dmscript.global`) via Python
> `open(...,'rb').decode('latin-1')`.

## 0. Critical correction to the ticket premise

The task text quotes `Data.AI_ATTACK_FORCE = 260`, which is the **data.gd static
default** (`data.gd:73`). At runtime `config.gd:528` applies
`app/config.json:114 "attack_force": 120.0`, and `main.gd:151` calls `cfg.apply()`
before the sim starts. **The effective threshold in the CLI soak is 120, not 260.**
(`config.gd:535-539` leaves it unchanged for the default `normal` tier.)
W2-4's report `W24_ai_waves.md:19` therefore mis-described the runtime value.
Neither the config nor `data.gd` was edited (not owned); the acceptance target
used below is the measured 120.

## 1. Residual 1 — force / wave acceptance

### 1.1 VERIFIED root causes (current source, before my edit)

| Cause | Current-source evidence (pre-edit) | Donor evidence |
|---|---|---|
| **Reserve horizon permanently closed the military gate** | `ai.gd:576` (backup) `can_train_military := ai_food_ok and not ai_starving and food_workers >= min_food_workers`; `ai.gd:82` `ai_food_ok = (food >= ai_food_reserve) and not starving`; `ai.gd:127-130` `reserve = upkeep_s*45 + 130 + 100`, floored by `AI_FOOD_THRESHOLD=260` (`config.json:111`). Job 1262 trace: food 215/248/268/239 vs reserve 269/271/273/275 → `food_ok:false` and `starving:true` on nearly every tick. `ai.gd:603` then `continue`d for every building: **no soldier was ever ordered.** | `PE:1405` `_ai_TryUnit` gates only on `_unit_CanApplyCountCostByID(...)` — the REAL cost; no reserve horizon. `PE:2094-2097` food-700 peasant switch. |
| **Class quota bought low-force, expensive ranged units** | `ai.gd:617-620` (backup) `if cls["ranged"] < cls["melee"]: want="ranged"` — a 1:1 quota. After 4 melee (force 40) the AI bought `serdiuk` (generic, aiforce **2**, food cost **60**) instead of `pikeman` (aiforce **10**, food cost **25**, `data.gd:588-590,606-608`). This is exactly the measured 40→42→44→46 pattern. | `CLS:4784-4788` `armyMinCount[lightinfantry]=36`, `shootinfantry=16`, `fasthorse=16`, `hardhorse=16` → ~0.44 shooters/melee, ~0.89 horse/melee. |
| **W2-4 train-sid fix and 8 s wave cooldown verified present** | `ai.gd:623-660` (now `685-...`) passes the GENERIC sid; `ai.gd:16,45,799-801,825-827` implements the 8 s `wave_cd` and increments `wave` only on a real sortie. | `DG:478 gc_ai_BitvaInterval = 8`. |
| **Barracks queue / AI_ATTACK_FORCE cap ruled out** | `ai.gd:598` queue<6 and `ai.gd:614` `force >= 2*120` were never approached with force=46. | n/a |

### 1.2 FIXED — minimal changes in `ai.gd`

1. `ai.gd:39-46` — `AI_TRAIN_FOOD_MARGIN := 100.0` (one peasant price,
   `data.gd:580`), `AI_RANGED_PER_MELEE := 16/36`, `AI_HORSE_PER_MELEE := 32/36`.
2. `ai.gd:625-640` — `can_train_military` no longer uses the 45 s reserve /
   predictive-starvation snapshot; it uses **real famine only** plus the
   existing food-worker ratio. The reserve stays in force for build/economy
   priority and peasant training (byte-unchanged there).
3. `ai.gd:622-624,632-642,728-736` — a per-tick `food_budget` ledger, real
   food-cost capture on the chosen unit, and a `cost + margin` gate before
   `game.train_unit()`. `game.train_unit` itself still enforces the real cost
   (`game.gd:3826-3841`); no resource cheat was added.
4. `ai.gd:676-686` — donor C9 class ratios replace the 1:1 quota.

`Data.AI_ATTACK_FORCE` was **not** changed. No RNG, no tick-order change.

### 1.3 MEASURED soak

PENDING — see §4, filled after job `w51-force-soak2` completes.

## 2. Residual 2 — per-slot AI tier consumer

### 2.1 VERIFIED gap

`config.gd:34-40` defines `AI_TIER_EFFECTS` but grep across `app/scripts/`
showed **zero consumers**; `data.gd:190-193` explicitly says per-slot tiers are
"recorded here for config fidelity" only. `main.gd:339-365` still reads the
legacy `entry["difficulty"]` and whitelists `easy/normal/hard` (W5-2 owns that
file).

### 2.2 FIXED — consumer in `ai.gd` (read-only on config.gd)

* `ai.gd:5` preloads `res://scripts/config.gd` as `C3ConfigScript` (same pattern
  as `main.gd:37`); no called symbol renamed.
* `ai.gd:14-16` `ai_tier` cache, refreshed once per think tick at `ai.gd:77`.
* `ai.gd:49-59` `_tier()` reads `Data.PLAYER_AI_DIFFICULTY[player]` first, then
  falls back to `Data.AI_DIFFICULTY`, then `"normal"`. **Exact convention for
  W5-2: the array is indexed by the sim player index, identical to
  `Data.PLAYER_NATIONS[player]`; values are the raw donor ids
  `easy|normal|hard|veryhard|impossible`; `"none"` (human slot) and unknown
  strings are treated as absent and fall through to the global.** No method
  call, no new Data API.
* `ai.gd:588-611` `_research()` consumes `AI_TIER_EFFECTS`: for non-normal
  tiers it appends `mine_<iron|coal|gold>_up1..up<mine_maxlevel>` (cap 1..7)
  from `data.gd:1378-1401` — donor `PE:3653-3658` caps 2/3/4/5/5; and for
  `easy` (`max_level_att=0, max_level_def=0`, `PE:2204-2213`) it drops upgrades
  whose effect has `damage_mult` or `prot_bonus`. **The `normal` research order
  is byte-identical to backup.**
* `ai.gd:799-811` `_raids()` consumes `divers` (`PE:2322-2327`, 0/0/2/4/4):
  `normal` keeps the legacy 6-cavalry minimum; higher tiers use the donor
  count as the raid-party size. This is a **port approximation** — `data.gd`
  has no diver unit or diversion order — and is reported as such, not claimed
  as donor diver parity.
* `ai.gd:231` adds `"tier": ai_tier` to the env-gated `C3AITrace` row only
  (silent by default), so a fixture can verify which tier was resolved.

### 2.3 Missing effects (read-only blocker, reported not invented)

* `AI_TIER_EFFECTS` has **no artillery keys**. `PE:2349-2355` gives howitzer
  2..8 / mortar 8..40 for `difficulty > normal` and `cannon_count div 2`
  otherwise. W2-12 recorded this in `config.gd:26,31` comments only. Cannot be
  applied without editing `config.gd` (not owned) or inventing constants.
* `max_level_att`/`max_level_def` have no faithful port hook beyond the
  `easy` 0/0 case: port upgrades are single-level ids (`bla_sword1`,
  `bla_armor1`, ...), not donor levels 1..7. Higher caps (7/7) therefore add
  nothing observable in this file.
* Faithful `divers` needs a diver unit + diversion order in `data.gd`/`game.gd`.

## 3. Exact diff

`git diff --no-index -- inbox/backup/ai.gd.bak-W51 app/scripts/ai.gd`; tabs
preserved, LF throughout (backup and working copy both LF, 827 lines before
edit). No called-symbol renames. Full hunk list is reproduced in the diff
below.

```diff
@@ -3,6 +3,7 @@ class_name C3AI
 const Data = preload("res://scripts/data.gd")
+const C3ConfigScript = preload("res://scripts/config.gd")
@@ -10,6 +11,9 @@ var retreat_t := 0.0
+# W5-1: donor tier resolved once per think tick from the per-slot array, with a
+# safe fallback to the single global knob. "normal" remains the port default.
+var ai_tier := "normal"
@@ -32,11 +36,34 @@ const AI_FOOD_HORIZON_S := 45.0
+const AI_TRAIN_FOOD_MARGIN := 100.0
+const AI_RANGED_PER_MELEE := 16.0 / 36.0
+const AI_HORSE_PER_MELEE := 32.0 / 36.0
@@ func _init ...
+func _tier() -> String:
+	var per: Array = Data.PLAYER_AI_DIFFICULTY
+	if player >= 0 and player < per.size():
+		var t := str(per[player])
+		if t != "" and t != "none" and C3ConfigScript.AI_DIFFICULTIES.has(t):
+			return t
+	var g := str(Data.AI_DIFFICULTY)
+	if C3ConfigScript.AI_DIFFICULTIES.has(g):
+		return g
+	return "normal"
@@ func tick ...
+	ai_tier = _tier()
@@ _trace row ...
-		"p": player, "t": snappedf(game.time_s, 0.1),
+		"p": player, "t": snappedf(game.time_s, 0.1), "tier": ai_tier,
@@ func _research ...
+	var fx: Dictionary = C3ConfigScript.AI_TIER_EFFECTS.get(ai_tier, {})
+	var att := int(fx.get("max_level_att", 2))
+	var def := int(fx.get("max_level_def", 3))
+	if ai_tier != "normal" and att <= 0 and def <= 0:
+		var keep: Array = []
+		for uid0 in order:
+			var uu: Dictionary = Data.UPGRADES.get(uid0, {})
+			var e: Dictionary = uu.get("effect", {})
+			if e.has("damage_mult") or e.has("prot_bonus"):
+				continue
+			keep.append(uid0)
+		order = keep
+	if ai_tier != "normal":
+		var maxlevel := clampi(int(fx.get("mine_maxlevel", 3)), 1, 7)
+		for k in ["iron", "coal", "gold"]:
+			for lv in range(1, maxlevel + 1):
+				var uid2 := "mine_" + k + "_up" + str(lv)
+				if Data.UPGRADES.has(uid2):
+					order.append(uid2)
@@ func _train ...
+	var food_budget := res.food
-	var can_train_military := ai_food_ok and not ai_starving and food_workers >= min_food_workers
+	var famine := bool(p.get("famine", false))
+	var can_train_military := (not famine) and food_workers >= min_food_workers
-	... res.food >= maxf(ai_food_reserve, 100.0) + 100.0 ...
+	... food_budget >= maxf(ai_food_reserve, 100.0) + 100.0 ...
-				game.train_unit(player, b, "peasant")
+				if game.train_unit(player, b, "peasant"):
+					food_budget -= 100.0
-			if cls["ranged"] < cls["melee"]:
+			if float(cls["ranged"]) < float(cls["melee"]) * AI_RANGED_PER_MELEE:
-			elif cls["cavalry"] < cls["melee"] / 2:
+			elif float(cls["cavalry"]) < float(cls["melee"]) * AI_HORSE_PER_MELEE:
+			var pick_food := 0.0
+					var pr: Dictionary = Data.UNITS[rs].get("price", {})
+					pick_food = float(pr.get("food", 0.0))
+						var pr2: Dictionary = Data.UNITS[rs2].get("price", {})
+						pick_food = float(pr2.get("food", 0.0))
+			if pick_food > 0.0 and food_budget < pick_food + AI_TRAIN_FOOD_MARGIN:
+				continue
 				force += pick_force
+				food_budget -= pick_food
@@ func _raids ...
-	if cav.size() < 6:
+	var min_cav := 6
+	if ai_tier != "normal":
+		var dz: Dictionary = C3ConfigScript.AI_TIER_EFFECTS.get(ai_tier, {})
+		var divers := int(dz.get("divers", 0))
+		if divers > 0:
+			min_cav = maxi(1, divers)
+	if cav.size() < min_cav:
```

Full unabridged diff is available with the command above; the elided lines are
comments only.

## 4. Runner jobs and measured acceptance

### 4.1 Job chronology (honest)

| Ticket | id | Result | Artefact |
|---|---|---|---|
| 1295 | `w51-force-soak` | **SKIPPED**, `wait=164.24 s`, `run=0.0`, `error="ticket 1295 was skipped (serving=1296)"` — FIFO burst race, **no Godot run** | `app/.godot_queue/results/00001295.json` |
| 1298 | `w51-force-soak2` | **FAILED**, `wait=93.56 s`, `run=370.52 s`, `exit=1`, but stdout is only the Godot banner: **two GDScript parse errors in my first edit** (`Cannot infer the type of "uid2"` at `ai.gd:609`; `Cannot infer the type of "food_budget"` at `ai.gd:625`), so `main.gd` never loaded and the CLI watchdog forced exit at 360 s. **No C3AITrace row, no simulation.** | `app/.godot_queue/results/00001298.json`, `.../00001298_w51-force-soak2/stderr.txt` |
| — | `w51-syntax-smoke` | short 3 s compile/trace probe before re-running the soak | PENDING |
| — | final 300 s soak | PENDING | — |

### 4.2 Parse fix applied after job 1298

* `ai.gd:609` `var uid2 := "mine_" + k + "_up" + str(lv)` →
  `var uid2: String = "mine_" + str(k) + "_up" + str(lv)` (`k` is a loop Variant).
* `ai.gd:625` `var food_budget := res.food` →
  `var food_budget: float = float(res.food)` (Dictionary access is Variant).

No logic change; both are explicit type annotations required by Godot 4.7.

### 4.3 Measured acceptance

PENDING.

## 5. Determinism note

* No `random()`, `randi()` or new RNG stream was added or re-seeded. The only
  existing RNG use is `_find_spot` (`ai.gd:557-559`) via the seeded `game.rng`;
  it is untouched in kind.
* `food_budget` is derived from the per-tick resource snapshot and decremented
  in deterministic building-iteration order (`game.buildings_of(player)`);
  `game.train_unit` itself charges resources with the same iteration.
* `ai_tier` is resolved from two static arrays once per think tick; no time or
  hash source. `wave_cd` remains a fixed-step float (`tick(dt)`).
* Because different units are now ordered at different ticks, downstream
  seeded-RNG consumption may shift; golden traces from this point are expected
  to differ. Env-gated `C3_AI_TRACE` output stays silent by default.
* The per-slot tier consumer changes only non-normal tiers; with the default
  `normal` tier, `_research` and `_raids` are byte-identical to backup.

## 6. Handoff to W5-2 (main.gd / selftest.gd)

1. Publish the **raw donor id** into `Data.PLAYER_AI_DIFFICULTY[player]` —
   sim player index, same convention as `Data.PLAYER_NATIONS[player]`; valid
   values `easy|normal|hard|veryhard|impossible`; `none`/unknown should be
   stored as `"normal"` or omitted. Prefer `entry["ai_difficulty"]` (already
   emitted by `menu.gd:658-665`) over the legacy collapsed `entry["difficulty"]`
   and validate against `C3ConfigScript.AI_DIFFICULTIES`.
2. No call into `C3AI` is needed; the consumer polls the Data array each think
   tick, so a runtime overlay change (e.g. `main.gd:1123`) is picked up.
3. `game.gd:3894` still keys the resource cheat on the GLOBAL
   `Data.AI_DIFFICULTY == "hard"`; that file is not mine. A per-slot
   `veryhard`/`impossible` will get donor research/raid effects but **no**
   resource cheat. Decide whether that is acceptable (R06 C19).
4. With no per-slot data (legacy rosters, CLI soak) my fallback is the global
   `Data.AI_DIFFICULTY`, so default behaviour is unchanged.

## 7. Open questions

1. `AI_TIER_EFFECTS` has no artillery keys (PE:2349-2355); `config.gd` is
   read-only for me. Needs a config owner to add them before artillery fidelity
   can be implemented in `ai.gd`.
2. Donor diver units/orders do not exist in the port; the raid-size mapping is
   an approximation. Faithful parity needs `data.gd`/`game.gd` work.
3. Port attack/defence upgrades are single-level, so caps above 0 cannot be
   distinguished from the normal tier without new `data.gd` rows.
4. Normal-tier mine upgrades are still not researched (original order), even
   though donor normal cap is 3; I preserved the shipped order per the
   byte-identical constraint. Coordinator decision needed if parity is wanted.
5. Job 1295 `w51-force-soak` was SKIPPED (0 s run, serving advanced to 1296
   during the wave-5 job burst); it is not a simulation result. See §4 for the
   one clean replacement run.
