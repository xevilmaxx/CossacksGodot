---
owner: W2-1 (micro-builder)
ticket: G-C2 / G-E2 / G-M1
date: 2026-11-24
wave: 2 (game-rules fixes)
scope: app/scripts/game.gd ONLY (+ this report)
backup: inbox/backup/game.gd.bak-W21
runner_job: 1259 (w21-capture-rules) — ok, 19.88 s
evidence: reports R02_capture_siege.md / R07_economy_market.md / R12_new_micro.md (read in full first)
---

# W21 — verified game-rules gaps in `game.gd`

Method: every claimed site was re-read in the **current** source before any edit.
Recon line numbers were treated as hints, not truth. Nothing was assumed DONE from
the board; where the current source already matched donor semantics it is marked
`VERIFIED-ALREADY`, not re-edited. Donor was never run or copied; all donor facts
below are quoted from the three recon reports (which used latin-1 reads).

## 1. Status table (file:line = current post-edit source unless labelled *pre*)

| # | Gap (source) | Status | Evidence / change |
|---|---|---|---|
| 1a | Donor capture modes govern **what may be captured**, port had `artillery_only` letting artillery capture buildings (R02 claim 3, G-C2) | **FIXED** | New `_building_capture_allowed()` at `game.gd:2727-2734`; capture gate at `game.gd:5294` now calls it. `artillery_only` → no building check at all (donor `building.inc/nothing.inc:311-324`); `no_peasants_or_centres` → `cen` frozen (replaces the old `centres_frozen` local at *pre*-`:5260`). `default`/`no_peasants` unchanged. |
| 1b | Peasant **target** conversion gated by `Data.CAPTURE_ENABLED` | **VERIFIED-ALREADY** | `game.gd:4907` (`_apply_hit`) still gates on `bool(Data.CAPTURE_ENABLED)`; `main.gd:301` sets it false for every non-default mode. This already matches donor "no peasant capture as targets"; no edit needed and `main.gd` is not mine. |
| 2a | Artillery may capture buildings in port (donor `bcancapture=False`, R02 claim 1) | **FIXED** | `_capture_unit_allowed()` at `game.gd:2740-2749` now rejects any unit whose `def.artillery` is true before the mode `match`. Artillery no longer contributes capturers to the building loop. |
| 2b | Peasants may capture buildings in port (same donor rule) | **NOT-DONE (deliberate)** | Left as-is on the coordinator's explicit constraint "without breaking the existing capturable-economy-building loop": `t_capture.gd:103-106` asserts four peasants take a town hall, and R02 claim 4 labels the continuous swarm capture a deliberate *video pass*. Gating peasants would fail that test. Needs owner/test decision — see §6/§7. |
| 3a | Gold-shortage ship/work stop (R07 claim 13, R09; T6-M01) | **FIXED (deterministic analogue)** | `game.gd:4009-4010` donor-literal consts (`4.0` gold, `100/32 s` delay); `_fire` gate at `game.gd:4831-4835`: any unit with `def.eat.gold` (officer/cannon/howitzer/mortar **and the `naval:true` yacht**, `data.gd:1041-1043`) stops firing and takes the donor-style delay while the owner has `<4` gold. No new RNG; pure state check. |
| 3b | Gold-shortage **desertion** / mercenary owner flip (R07 claim 12) | **NOT-DONE** | Port `new_player()` (`game.gd:288-304`) has no `is_mercenary` flag, no rebel player slot, and `data.gd` has no comparable key; the existing `_tick_upkeep` consequence is only `morale -= 10*dt` at `:4052-4055` (*pre*), still present at `game.gd:4080-4083`. Requires data keys + a destination owner — outside my file ownership. See §6. |
| 4 | HUD capture % divides by fixed `8.0 s` vs sim `5+max_hp/2500` (R02 claim 10) | **NOT-DONE (wrong file)** | Current site is **`hud.gd:889`** (recon said `:886`, drifted): `s += "  CAPTURE %.0f%%" % (float(first.capture_t) / 8.0 * 100.0)`. Exact change for W2-3 in §6. `hud.gd` is not mine. |
| 5 | AI building captures spam human chat via raw `say()` (R02 claim 11) | **FIXED** | `game.gd:5360`: `say("A building was captured!")` → `_say_human(capturer, "A building was captured!")` (helper at `game.gd:2805-2807`). Also routed the sibling capture path `game.gd:4916` (`_say_human(int(e.player), "Enemy peasant captured!")`, previously `if e.player == 0: say(...)`) — behaviour-preserving for humans, silent for AI. |
| 6a | Capture cancels victim's queue + in-progress upgrade (R12-04) | **FIXED** | `game.gd:5355-5356`: on owner flip `e["queue"] = []` and `e["research"] = null` (donor `miscext.script:1115-1132`, `_unit_ClearOrders` / `_unit_CancelUpgradePerform`). No refund, matching R12. Note `e.queue` and `e.research` are both serialized by `dump_state` (`game.gd:5466`/`:5468`), so this is an intentional donor-required dump delta in capture scenarios. |
| 6b | Artillery captures ~4× faster (R12-05) | **NOT-DONE (conflicts with 2a)** | Site `game.gd:5322` (`speed_c = peas*1 + sols*0.25`) unchanged. R12-05's donor ratio `19/5` cannot be applied to a unit kind that gap 2a now forbids from capturing buildings; mutually exclusive recon claims need an owner ruling before wiring. |
| 6c | Capture blocked by nearby gunfire / `bblockshot` (R12-03) | **NOT-DONE** | R12 open question 3 states donor intent is **inferred** (delay is applied to the captured object, not the capturer) and needs a live capture-under-fire check; MED determinism risk (shot-event ordering). No edit. |
| 6d | Staged/randomised corpse decay (R12-06) | **NOT-DONE** | R12 itself says "table-only this pass ... must be routed through the seeded sim RNG ... do not bundle casually"; donor uses `random*(time/1)`. Also needs `data.gd:56 CORPSE_LIFE` (not mine). No new RNG per this ticket's determinism rule. |
| 6e | Log-message ticker / off-screen alarm (R12-01/02) | **NOT-DONE (other files)** | Need `hud.gd`, `main.gd`, `data.gd`; no donor-backed site in `game.gd` beyond existing `post_event` calls. Excluded by ownership. |
| G-11 | AI demolition denial of mines before capture (R02 claim 9) | **NOT-DONE (other file + donor unverified)** | `ai.gd` is not mine; donor evidence is wiki-only, no script literal found. |

## 2. Exact diff applied (`git diff -- app/scripts/game.gd`)

```diff
@@ -2716,15 +2716,35 @@ func _is_ally(a: int, b: int) -> bool:
-# T-MENU-ROSTER donor "Capture" rule. Peasant conversion is already gated by
-# Data.CAPTURE_ENABLED (main clears it for the no-peasant modes); this decides
-# which units may lean on a building capture point.
+# DONOR capture-mode semantics (R02 claim 3): the skirmish option governs WHAT
+# may change owner, not who may lean on a capture point. Modes:
+#   default                 -> capturable units + buildings
+#   no_peasants             -> no peasant *target*, buildings still fall
+#   no_peasants_or_centres  -> same, plus the town hall itself is frozen
+#   artillery_only          -> only artillery objects; buildings NEVER checked
+# The port has no artillery-object owner flip, so `artillery_only` disables the
+# building-capture path entirely (donor building.inc/nothing.inc:311-324).
+func _building_capture_allowed(e: Dictionary) -> bool:
+	match str(Data.CAPTURE_MODE):
+		"artillery_only":
+			return false
+		"no_peasants_or_centres":
+			return str(e.get("sid", "")) != "cen"
+		_:
+			return true
+
+# DONOR bcancapture=False on peasants and artillery (unit.script:461-470,
+# :1198, :1721+): only soldiers may capture buildings. The port keeps peasant
+# swarming as its tested "video pass" loop (t_capture.gd:103-106), so peasants
+# stay eligible; artillery is gated out of the building path here.
 func _capture_unit_allowed(u: Dictionary) -> bool:
+	if bool((u.get("def", {}) as Dictionary).get("artillery", false)):
+		return false
 	match str(Data.CAPTURE_MODE):
 		"no_peasants", "no_peasants_or_centres":
 			return str(u.get("sid", "")) != "peasant"
 		"artillery_only":
-			return bool((u.get("def", {}) as Dictionary).get("artillery", false))
+			return false
 		_:
 			return true
@@ -3980,6 +4000,14 @@
 const _UPKEEP_RES_IDX := [0, 3, 2]
+# DONOR T6-M01 (unit.script:8185-8201): bturnoff units stop firing while the
+# owner has <4 gold, with a 100-frame attack delay. Port has no bturnoff flag;
+# the deterministic analogue is gold-upkeep units (def.eat.gold), which
+# includes the naval yacht (data.gd:1043). Threshold is the donor literal 4;
+# a config key (economy.gold_fire_stop_res / _seconds) is needed to make it
+# tunable - data.gd/config.gd are owned by another worker.
+const _GOLD_FIRE_STOP_RES := 4.0
+const _GOLD_FIRE_STOP_S := 100.0 / 32.0
@@ -4798,6 +4826,12 @@ func _fire(e: Dictionary, t: Dictionary, w: Dictionary, bonus := 0) -> void:
 	if not cost.is_empty() and not Data.can_pay(players[e.player].res, cost):
 		e.cooldown = 1.0
 		return
+	# DONOR T6-M01: gold-upkeep units (incl. ships) stop firing when the owner
+	# has <4 gold; deterministic state check, no new RNG.
+	if (e.def.get("eat", {}) as Dictionary).has("gold") \
+			and float(players[e.player].res[_UPKEEP_RES_IDX[1]]) < _GOLD_FIRE_STOP_RES:
+		e.cooldown = _GOLD_FIRE_STOP_S
+		return
@@ -4879,8 +4913,7 @@ func _apply_hit(...):
-		if e.player == 0:
-			say("Enemy peasant captured!")
+		_say_human(int(e.player), "Enemy peasant captured!")
@@ -5256,9 +5289,9 @@ func _tick_building(e: Dictionary, dt: float) -> void:
-	var centres_frozen := str(Data.CAPTURE_MODE) == "no_peasants_or_centres" and str(e.sid) == "cen"
-	if e.finished and e.def.get("capture", false) and not centres_frozen:
+	if e.finished and e.def.get("capture", false) and _building_capture_allowed(e):
@@ -5316,9 +5349,15 @@ func _tick_building(e: Dictionary, dt: float) -> void:
+				# R12-04: donor _unit_ClearOrders / _unit_CancelUpgradePerform
+				# (miscext.script:1115-1132) fire on capture - queued production
+				# and any in-progress upgrade are lost; no refund to old owner.
+				e["queue"] = []
+				e["research"] = null
 				e.erase("rally")
 				post_event("capture", e.pos, e.sid)
-				say("A building was captured!")
+				# R02 claim 11 / P-44: do not spam the human chat for AI captures.
+				_say_human(capturer, "A building was captured!")
```

No called symbol was renamed. `_capture_unit_allowed` and `say` keep their names;
`_building_capture_allowed` is a new private helper, not a rename.

## 3. Backup / test evidence

- Backup: `inbox\backup\game.gd.bak-W21` (218,503 bytes, copied before the first edit).
- Targeted test (one only, per instruction — **no full selftest**):
  `python app\tools\godot_runner.py run --id w21-capture-rules --timeout 90 -- --headless --path app --script res://tests/t_capture.gd`
- Runner: ticket **1259** `w21-capture-rules` **START → END ok**, 19.88 s.
- Result `app/tests/results/t_capture.json`: **`"passed": true`, 6/6 checks** —
  `town_hall_capturable_by_peasants`, `mine_deposit_captured_with_mine`,
  `foreign_town_hall_unlocks_nation`, `capture_precondition_guard_blocks`,
  `economy_buildings_capturable`, `military_buildings_not_capturable`.
  The captured-economy-building loop and the peasant swarm are intact.
- Side effect of the test run: `app/tests/results/t_capture.json` was regenerated
  (now `unix_ms` 1795510548238) — that is the test's own output, not a code edit.

## 4. Determinism note

- **No new RNG and no new `random`/`rng` calls.** All added branches read existing
  deterministic state only: `Data.CAPTURE_MODE`, `e.sid`, `def.artillery`,
  `def.eat.gold`, `players[e.player].res[3]`.
- No new entity iteration, no new spawns, no new `post_event` sites, no change to
  grid query order. `say`→`_say_human` changes only chat emission, never sim state.
- Default-mode seed dumps are unchanged for ordinary play. Intentional,
  donor-required deltas occur only in scenarios that trigger the new rules:
  (a) artillery inside a capture ring no longer counts as a capturer;
  (b) `artillery_only` skips building capture entirely (mode-scoped);
  (c) a captured building's `queue`/`research` are cleared (R12-04);
  (d) gold-upkeep units stop firing while owner gold `<4` (T6-M01 ship-stop).
- Peasant capture in `default` mode is intentionally preserved, so the existing
  `t_capture` seed path and its byte-identity are untouched.

## 5. Needed changes owned by others (NOT edited here)

| Owner | File / line | Exact change |
|---|---|---|
| **W2-3 (hud.gd)** | `app/scripts/hud.gd:889` | Replace `float(first.capture_t) / 8.0 * 100.0` with `float(first.capture_t) / (5.0 + float(first.get("max_hp", 0.0)) / 2500.0) * 100.0` — same formula as `game.gd:5330`. Acceptance: half-filled `cen` (5300 hp), `mine_gold` and `sto` each read 50 % ±1. Readout-only, no determinism risk. |
| **data.gd / config.gd owner** | `data.gd` (~`UNITS_BASE` at :644-740, :1040) + `config.gd` economy block (:80-90, :474-484) | Add `economy.gold_fire_stop_res` (donor literal `4`) and `economy.gold_fire_stop_seconds` (donor 100 frames / 32 fps = `3.125`); replace the two `game.gd` consts with `num(...)` lookups. For full desertion: add `is_mercenary` unit def flag, `economy.gold_desert_delay_s`, and a rebel owner slot/mechanic. |
| **ai.gd owner** | `app/scripts/ai.gd` | G-11 denial of mines before capture — donor evidence is wiki-only (R02 claim 9); needs its own determinism-safe ticket. |
| **hud.gd / main.gd / data.gd owner** | see R12-01 / R12-02 | 23-slot log ticker + off-screen alarm event (icons, wording and frustum proxy are unresolved in R12 open questions 1/2/4). |
| **test owner** | `app/tests/t_capture.gd` | If the owner rules that peasants must **not** capture buildings (full donor `bcancapture`), rewrite checks at `:52-59,103-106` to use soldiers and add the 4-mode matrix from R02 rank 1. |

## 6. Open questions

1. **Peasant building-capture parity.** Donor `bcancapture=False` (R02 claim 1) says peasants cannot capture buildings; the port's tested loop says they can. I preserved the loop per the task constraint. Does the coordinator accept this as `ACCEPTED DIVERGENCE` (consistent with R02 claim 4's "video pass"), or should `t_capture` be rewritten by the test owner?
2. **Artillery conflict.** R02 claim 1 (artillery cannot capture buildings) and R12-05 (artillery captures ~4× faster) are mutually exclusive. Which governs? R12-05 was not implemented pending this ruling.
3. **`bblockshot` intent** (R12 open Q3): donor applies the attack delay to the captured object, not the capturer. Confirm intent with a live capture-under-fire before wiring R12-03.
4. **Desertion destination.** Donor moves mercenaries to a special `plMercHnd` rebel player. The port has no such slot; should desertion instead kill/despawn the unit, flip it to the nearest enemy, or add a dedicated rebel player (which changes victory/elimination logic at `game.gd:5383,5410`)?
5. **Gold-stop scope.** I applied the donor `<4` gate to every `eat.gold` unit (officers, cannons, howitzers, mortars, yacht) as the `bturnoff` analogue. Donor's literal `bturnoff` set (unit.script:1979 + others) may be narrower; a donor-byte enumeration would sharpen the predicate.
6. **Cooldown magnitude.** Used donor's 100 frames at the port's 32-frame-second (=3.125 s). If the port's `gc_frames_to_time` equivalent differs, tune `_GOLD_FIRE_STOP_S`.

---
**Files changed by this worker:** `app/scripts/game.gd` only, plus this report.
**Full selftest:** not run (coordinator final gate). One targeted runner job only: 1259.
