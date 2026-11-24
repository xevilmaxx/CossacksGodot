---
owner: W2-4
decision: D-22
date: 2026-11-24
area: app/scripts/ai.gd only (+ this report)
backup: inbox/backup/ai.gd.bak-W24
charter: exclusive ai.gd; no direct Godot (runner only); one targeted soak, no full selftest
gaps: G-AI3 / G-AI4 / R06 C7+C8 / I06 open question 1
runner_job: 1262 w24-ai-wave (env C3_AI_TRACE=1)
status: CODE FIXED / SOAK FAILED (exit 1) / wave acceptance UNVERIFIED
---

# W2-4 — AI wave cadence, famine miner floor, force-stall root cause

## 0. Verification policy applied

Every "gap" was re-read in the **current** `app/scripts/ai.gd` before editing. Donor files were
read private-use, read-only, via Python `open(...,'rb').decode('latin-1')`. `Data.AI_ATTACK_FORCE`
is **260.0** in current `app/scripts/data.gd:73` (R06's "120" text is stale); this threshold was
NOT changed, per charter. `Data.AI_THINK_INTERVAL=1.0` (`data.gd:69`).

## 1. Per-gap verdict table

| Gap | Donor evidence (path:line) | Port location before → after | Verdict | Measured result |
|---|---|---|---|---|
| **C8 / G-AI3 wave cadence** | `C:\Games\Cossacks 3\data\scripts\dmscript.global:478` `gc_ai_BitvaInterval = 8;`; battle-time gate `units/global.inc/progresswarai.inc:1122` `if GetGameTime - TArmy(pArmy).fLastBattleTime > gc_ai_BitvaInterval then` | `ai.gd:680,694` (old `wave += 1` on every think tick) → `ai.gd:16,43-45,796-828` (`wave_cd` decremented by fixed `dt` each sim step; sortie gated; `wave` increments only when an order was actually issued; `wave_cd=8.0`) | **FIXED (code) / NOT-DONE (behaviour proof)** | Job 1262 shows `wave=0` at every row because `force` never reached 260; the 8 s cadence path was **never exercised** → cadence remains UNVERIFIED by soak. |
| **C7 / G-AI3 famine miner floor** | `units/global.inc/progresseconomicai.inc:795-799` `if (gTmpIntList.GetCount>4) then ... SetCount(GetCount-4); // always have 4 peasants for wood and stone` | `ai.gd:310-323` (old override recalled all miners) → `ai.gd:34,321-339` (`AI_FAMINE_WOODSTONE_FLOOR=4`; first 4 wood/stone workers protected by stable array order) | **FIXED (code) / NOT-DONE (real-famine proof)** | In job 1262 `starving:true` rows keep `jobs.stone=3, wood=2` (5 protected), but `famine` is `false` in every row, so only the predictive-shortfall branch was exercised; the donor's hard-famine case is untested. |
| **G-AI4 / I06 open Q1 force stall at 40** | No donor analogue needed: pure port bug | `ai.gd` old `:598-609` (resolved sid passed to `train_unit`) → new `:623-660`; `game.gd:3720` gate read-only | **FIXED (code) + partial measured recovery** | Pre-fix job 1247: `force=40, military=4` frozen from t=69 to t=299. Post-fix job 1262: `force=40 (t=69) → 42 (t=80) → 44 (t=91) → 46 (t=102)`, `military 4→5→6→7`. Still **MEASURED below 260**; not a PASS. |
| **I06 metal mines (already landed)** | — | `ai.gd:384-397` unchanged by me | **VERIFIED-ALREADY** | Both mines present in job 1262 (`blds.mine_iron=1`; `mine_coal` not yet reached by t=102). |

### Root cause of the force stall (evidence, not guess)

`ai.gd` picked a **nation-resolved** sid: for `nat="rus"`, `Data.resolve_sid("rus","serdiuk") =
"strelet"` (`data.gd:244,1266-1269`). It then called `game.train_unit(player,b,"strelet")`, but
`game.gd:3720` refuses unless `building.def.trains.has(sid) OR .has(rsid)`; `bar.def.trains`
(`data.gd:1060`) contains `serdiuk`, `archer`, … — **not** `strelet`. After four melee units the
class-quota logic (`cls.ranged < cls.melee` ⇒ `want="ranged"`) selected that mapped ranged unit,
so every subsequent tick failed `train_unit` and `force` froze at 40 (`4 × aiforce 10`).
The fix passes the **generic** sid (`serdiuk`) to `train_unit` (which resolves it itself) and keeps
the resolved sid only for the `_kind_class` check and `aiforce`; a deterministic `def.trains` fallback
covers buildings that cannot train the currently wanted class. The post-fix 5th unit has
`aiforce=2` (= `strelet`), exactly as predicted. `game.gd`/`data.gd` need **no change** for this.

## 2. Exact diff (`git diff -- app/scripts/ai.gd`, tabs preserved; line numbers final)

Four hunks, all in `app/scripts/ai.gd`; no called-symbol renames, no config/data/game edits.

```diff
@@ -10,6 +10,10 @@ var think_t := 0.0
 var wave := 0
 var raid_ids: Array = []
 var retreat_t := 0.0
+# T6-W24: donor gc_ai_BitvaInterval=8 (dmscript.global:478). Real-time cooldown
+# between sorties; decremented by the fixed sim step in tick(), so it is
+# deterministic and independent of the 1 s think interval.
+var wave_cd := 0.0
@@ -25,6 +29,9 @@ const AI_WOOD_FLOOR := 260.0
 const AI_STONE_FLOOR := 160.0
 # Seconds of whole-army upkeep kept as a live buffer before new soldiers train.
 const AI_FOOD_HORIZON_S := 45.0
+# Donor progresseconomicai.inc:795-799 keeps 4 peasants on wood/stone through
+# the famine recall ("always have 4 peasants for wood and stone").
+const AI_FAMINE_WOODSTONE_FLOOR := 4
@@ -33,6 +40,9 @@ func _init(g: C3Game, p: int) -> void:
 func tick(dt: float) -> void:
 	if not Data.AI_ENABLED:
 		return
+	# T6-W24: accumulate every fixed step, not only think ticks, so the 8 s
+	# donor-style battle interval stays exact and replay-stable.
+	wave_cd = maxf(0.0, wave_cd - dt)
 	think_t -= dt
@@ -308,10 +318,25 @@ func _economy(...):
 	var famine := bool(p.get("famine", false))
+	# T6-W24: donor floor (PE:795-799) — never recall the first 4 wood/stone
+	# workers. Stable peasants-array order is the tie-break, so no RNG is used
+	# and the same replay always protects the same workers.
+	var protected: Dictionary = {}
+	if ai_starving:
+		var ws: Array = []
+		for pe4 in peasants:
+			if pe4.inside_of != 0:
+				ws.append(pe4)
+			elif pe4.order.type == "gather" and str(pe4.order.get("res", "")) in ["wood", "stone"]:
+				ws.append(pe4)
+		for i in range(mini(AI_FAMINE_WOODSTONE_FLOOR, ws.size())):
+			protected[int(ws[i].id)] = true
 	if ai_starving:
 		for pe in peasants:
 			if pe.order.type == "resow" or (not famine and pe.inside_of == 0):
 				continue
+			if protected.has(int(pe.id)):
+				continue
@@ -595,18 +620,44 @@ func _train(...):
 			var want := "melee"
 			if cls["ranged"] < cls["melee"]:
 				want = "ranged"
 			elif cls["cavalry"] < cls["melee"] / 2:
 				want = "cavalry"
 			elif cls["artillery"] < 3 and b.sid == "art":
 				want = "artillery"
+			# T6-W24: train_unit() validates against the GENERIC sid held in
+			# building.def.trains (game.gd:3720) and resolves the nation itself.
+			# Passing an already-resolved sid ("strelet" for rus "serdiuk") made
+			# that gate fail forever: the 1247 soak stopped at force 40 / 4
+			# melee units as soon as the AI wanted its first ranged soldier.
+			# Use the resolved sid ONLY for the class check and the force value;
+			# order the GENERIC sid, which train_unit() accepts.
+			var nat: String = str(p.get("nation", ""))
+			if nat == "":
+				nat = str(Data.PLAYER_NATIONS[player])
 			var pick := ""
+			var pick_force := 0.0
 			for o in b.def.trains:
-				var rs: String = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]), str(o))
+				var rs: String = Data.resolve_sid(nat, str(o))
 				if not Data.UNITS.has(rs):
 					continue
 				if game._kind_class({"def": Data.UNITS[rs], "kind": "unit"}) == want:
-					pick = rs
+					pick = str(o)
+					pick_force = float(Data.UNITS[rs].aiforce)
 					break
+			if pick == "":
+				# Fallback: a barracks cannot train cavalry/artillery. Without
+				# this the class quota idled the queue forever once ranged
+				# caught up with melee. Produce any combat unit this building
+				# can train; def.trains order makes the choice deterministic.
+				for o2 in b.def.trains:
+					var rs2: String = Data.resolve_sid(nat, str(o2))
+					if not Data.UNITS.has(rs2) or bool(Data.UNITS[rs2].get("support", false)):
+						continue
+					var kc2: String = game._kind_class({"def": Data.UNITS[rs2], "kind": "unit"})
+					if kc2 in ["melee", "ranged", "cavalry", "artillery"]:
+						pick = str(o2)
+						pick_force = float(Data.UNITS[rs2].aiforce)
+						break
 			if pick == "":
 				continue
 			if game.train_unit(player, b, pick):
-				force += float(Data.UNITS[pick].aiforce)
+				force += pick_force
@@ -742,7 +793,12 @@ func _waves(...):
 	if enemy_home.is_empty():
 		return
-	wave += 1
+	# T6-W24: donor gc_ai_BitvaInterval=8 (dg:478). A sortie may only be
+	# ordered once per interval; the timer is consumed only when an order is
+	# actually issued, so a targetless or idle tick never burns the cooldown.
+	if wave_cd > 0.0:
+		return
+	var sortied := false
 	for m in military:
 		if m.order.type != "none" and m.order.type != "attackmove":
 			continue
 		var sq := game.squad_of_unit(m.id)
 		if not sq.is_empty():
 			var off: Dictionary = game.by_id.get(int(sq.officer), {})
 			if not off.is_empty() and not off.dead and off.order.type == "none":
 				game.cmd_attack_move(off, enemy_home.pos)
+				sortied = true
 			continue
 		var kc := game._kind_class(m)
 		if kc == "artillery":
 			game.cmd_attack_ground(m, enemy_home.pos)
+			sortied = true
 		elif kc == "ranged":
 			game.cmd_attack_move(m, enemy_home.pos + (home.pos - enemy_home.pos).normalized() * 14.0)
+			sortied = true
 		elif kc == "cavalry":
 			game.cmd_attack_move(m, enemy_home.pos + Vector2(10, -10))
+			sortied = true
 		else:
 			game.cmd_attack_move(m, enemy_home.pos)
+			sortied = true
+	if sortied:
+		wave += 1
+		wave_cd = 8.0
```

Backup: `Copy-Item app\scripts\ai.gd inbox\backup\ai.gd.bak-W24` → `BACKUP OK` (verified before edits).

## 3. Runner job and honest exit-cause analysis

Command (exactly as tasked, env prefixed in PowerShell):

```
$env:C3_AI_TRACE='1'; python app\tools\godot_runner.py run --id w24-ai-wave --timeout 400 -- --headless --path app -- --cli app/cli.json --cli-seconds 180 --timeout 360
```

`app/.godot_queue/results/00001262.json`: `status="failed"`, `exit=1`, `wait=179.96 s`,
`run=190.41 s`, hard timeout 400 s. `stderr.txt` = **0 bytes**. `stdout.txt` = 208 lines:
Godot banner + blank + **206 `C3AITrace` rows** (t=0…102, two players). No other text.

Why exit 1 — stated honestly:

* **Not a runner hard timeout**: `godot_runner.py:403-412` records `status="timed-out"`, `exit=-9`
  and appends `[runner] KILLED after 400s` to stderr on that path; none of that happened.
* **No observed in-app assertion or script error**: the only `_quit(1)` paths that print are the
  wall watchdogs (`main.gd:1130-1133` `printerr("watchdog: ...")`, `main.gd:1626-1628`
  `printerr("cli: wall-clock limit reached")`) and screenshot errors (`main.gd:1383,1393,1398,1407`);
  stderr and stdout contain none of these literals.
* **No normal CLI completion**: `main.gd:1648-1670 _finish_cli()` always prints the JSON report and
  calls `_quit(0)`. No JSON was printed, and `app/cli.json` was **not rewritten** (LastWriteTime
  09:31:36 vs job stdout 10:04:30 — still the I06 300 s report with `sim_seconds=300`).
* Therefore the Godot process terminated on a path that emitted no diagnostic at t≈102 sim s,
  ~190 s wall. Exact cause is **UNVERIFIED**; an external process kill (Windows `taskkill /F`
  returns 1) is the most consistent explanation given swarm activity, but I cannot prove it from
  the artefacts. **This job is a FAILED run and is not offered as an acceptance PASS.**

## 4. Observed trace lines (verbatim, player 0 = AI; `C3AITrace` from `ai.gd:157-209`)

Pre-fix comparison, job 1247 (I06 final code), `military=4` frozen:

```
... "force":40.0,...,"military":4,...,"t":69.0,"wave":0 ...
... "force":40.0,...,"iron":415.0,...,"military":4,...,"t":299.0,"wave":0 ...
```

Post-fix, job 1262 (`stdout.txt`, selected rows):

```
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},...,"food":262.0,"food_ok":true,"food_workers":5,"force":10.0,"gold":88.0,"iron":70.0,"jobs":{"build":2,"food":5,"idle":0,"mine":0,"other":0,"stone":3,"wood":2},"military":1,"mills_all":1,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,"peasants":12,"reserve":260.0,"starving":false,"stone":0.0,"stone_d":64.0,"t":56.0,"wave":0,"wood":70.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},...,"food":215.0,"food_ok":false,"food_workers":6,"force":40.0,"gold":77.0,"iron":65.0,"jobs":{"build":2,"food":6,"idle":0,"mine":0,"other":0,"stone":3,"wood":2},"military":4,"mills_all":1,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,"peasants":13,"reserve":269.0,"starving":true,"stone":0.0,"stone_d":64.0,"t":69.0,"wave":0,"wood":70.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},...,"food":248.0,"food_ok":false,"food_workers":6,"force":42.0,"gold":66.0,"iron":60.0,"jobs":{"build":2,"food":6,"idle":0,"mine":0,"other":0,"stone":3,"wood":2},"military":5,"mills_all":1,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,"peasants":13,"reserve":271.0,"starving":true,"stone":0.0,"stone_d":64.0,"t":80.0,"wave":0,"wood":70.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},...,"food":268.0,"food_ok":false,"food_workers":6,"force":44.0,"gold":55.0,"iron":55.0,"jobs":{"build":2,"food":6,"idle":0,"mine":0,"other":0,"stone":3,"wood":2},"military":6,"mills_all":1,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,"peasants":13,"reserve":273.0,"starving":false,"stone":0.0,"stone_d":64.0,"t":91.0,"wave":0,"wood":70.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},...,"food":239.0,"food_ok":false,"food_workers":6,"force":46.0,"gold":33.0,"iron":45.0,"jobs":{"build":2,"food":6,"idle":0,"mine":0,"other":0,"stone":3,"wood":2},"military":7,"mills_all":1,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,"peasants":13,"reserve":275.0,"starving":true,"stone":0.0,"stone_d":64.0,"t":102.0,"wave":0,"wood":70.0}
```

(`...` only elides unchanged keys; the quoted key/value pairs are byte-exact from stdout.)

### Acceptance scorecard (MEASURED, no PASS claimed)

| Criterion | Result | Evidence |
|---|---|---|
| Force ≥ `Data.AI_ATTACK_FORCE` (260) | **FAIL / MEASURED NOT MET** | max `force=46.0` at t=102 (`military=7`); run ended early |
| `wave >= 1` | **FAIL / MEASURED NOT MET** — every row `wave=0` | no sortie possible below threshold |
| 8 s sortie interval | **UNVERIFIED** | cooldown code present, never triggered |
| Force resumes after the old 40 stall | **PASS (partial)** | 40 → 42 → 44 → 46; 4 → 7 units |
| 4-worker wood/stone floor in code | **PASS (static)** | `ai.gd:34,321-339`; `jobs.stone=3, wood=2` during `starving:true` rows |
| Donor hard-famine (`famine:true`) floor | **UNVERIFIED** | `famine=false` in all 206 rows |

No corrected job was queued. Do **not** queue another on my behalf without a fresh instruction.

## 5. Determinism note

* No RNG added or re-seeded; no `random()` call. `wave_cd` is a float decremented once per fixed
  sim step (`main.gd:1157-1166` uses `step = 1.0/Data.FPS` and calls `brain.tick(step)`), so the
  8 s gate is exact and replay-stable.
* Famine floor tie-break is the stable `game.units_of()` array order and integer unit ids, not a
  hash or draw.
* Training fix only changes **which sid string is passed** to `game.train_unit` (generic instead
  of nation-resolved); the seeded `game.rng` stream in `_find_spot` is untouched in kind, but
  because different units now spawn, downstream RNG consumption may occur at different ticks —
  golden traces from this point on are expected to differ. Env-gated `C3_AI_TRACE` output stays
  silent by default (`ai.gd:158`).

## 6. Needed changes owned by others

* **None required in `game.gd`/`data.gd` for these three fixes.** `game.gd:3720`'s generic-sid gate
  was correct; `ai.gd` now honours it. `Data.AI_ATTACK_FORCE=260` (`data.gd:73`) was deliberately
  left untouched.
* For an acceptance-grade wave proof, a longer/healthier soak is needed so `force` can reach 260:
  in job 1262 food oscillates ~225-355 with `reserve` ~273 and `starving:true` on most ticks,
  throttling `_train` through `can_train_military` (`ai.gd:576-579`). That is an economy/reserve
  tuning question (my file, but outside this ticket's "minimal" scope and no second soak was
  authorised) — coordinator decision needed.
* R06's stale "AI_ATTACK_FORCE=120" and "wave increments every think tick" prose should be
  reconciled against current `data.gd:73` and this fix.

## 7. Open questions

1. What caused job 1262 to exit 1 silently at ~190 s wall / t=102? No stdout/stderr diagnostic,
   no CLI JSON, not a runner timeout. Need runner/ops evidence (external taskkill?) — out of my
   ownership.
2. Is `wave` supposed to count **sorties issued** (my implementation) or **think ticks while an
   army is ready** (old behaviour)? Donor `PW:1122` gates a battle by time since last battle, so
   sortie-based is the closer reading, but no donor literal for the counter itself was found.
3. Does the donor floor mean 4 total wood+stone workers (implemented) or 4 each? `PE:797` says
   "always have 4 peasants for wood and stone" — total reading used.
4. With food oscillating around the reserve, `force` grows ~2 per 10 s post-fix; would a longer
   uninterrupted soak reach 260, or is the reserve horizon the next binding gate?
5. Job 1262 never reached `mine_coal`; I06's 300 s run did (at t=290). Truncated window, not a
   regression claim.
