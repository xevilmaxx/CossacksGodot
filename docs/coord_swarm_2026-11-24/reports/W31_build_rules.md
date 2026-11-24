---
owner: W3-1 (micro-builder)
date: 2026-11-24
scope: wave-3 building UX — sim-side build rules in app/scripts/game.gd only
files_touched:
  - app/scripts/game.gd
  - docs/coord_swarm_2026-11-24/reports/W31_build_rules.md
mode: donor read-only (bytes/latin-1, never run/copied); no RNG; minimal evidence-backed diffs
basis: reports/X01_building_ux_sites.md (C1,C3,C5,C8,C10,C11) + WAVE3_DECISIONS.md (rulings 3,4,6,7)
status: 4/4 directive items implemented; 1 targeted runner job green (caveat below)
---

# W3-1 — sim-side build rules (affordability, builders, rally, refund)

All claims re-verified in **current** source before and after patching. Line
numbers below are **post-edit** unless explicitly marked `pre`.

## Verdict table

| # | Directive item | Verdict | Evidence (post-edit file:line) |
|---|---|---|---|
| 1 | `build_cost` / `can_afford`, called before `pay_cost`, refuse site creation | **FIXED** (partly VERIFIED-ALREADY) | `game.gd:3671`, `:3690`, `:3734-3738` |
| 2 | Refuse human placement with zero selected peasants; AI unchanged | **FIXED** (partly VERIFIED-ALREADY) | `game.gd:3722-3732` |
| 3 | Re-arm default rally on capture | **FIXED** (default itself VERIFIED-ALREADY) | `game.gd:2070`, `:2093`, `:5430-5434` |
| 4 | Stale-site cancel/refund via `Data.refund(...,1.0)` unworked; document partial | **FIXED** (refund primitive VERIFIED-ALREADY) | `game.gd:4219-4237`, `:4242`, `:3744` |

### VERIFIED-ALREADY (present before this patch, left intact)

- **Escalated charge existed** — `place_building` already computed
  `pow(3.0,cnt)` for `cen` / `pow(1.5,cnt)` otherwise (skipping `mine_*`, `wal`,
  `gat`) and already refused with `"Not enough resources."` via `pay_cost`
  (`game.gd:3681-3693` pre). What was missing was a **callable** version for the
  HUD and an explicit gate *before* `pay_cost`.
- **Selected-peasant-only sending existed** — `place_building` never swept idle
  peasants; it only issued `cmd_build` for entries in `builders`
  (`game.gd:3699-3711` pre, comment still at `:3713-3715` today). The orphan
  path was the *absence of a refusal* when that array is empty.
- **Default rally existed** — `_on_building_finished` sets `e["rally"]` for any
  def with `trains`, and spawning reuses it (`game.gd:2087-2088` pre /
  `:2092-2093` now). Only the capture erasure had no re-arm.
- **Refund primitive existed** — `Data.refund(res, cost, percent)` at
  `data.gd:1555-1557`, already used for training-queue cancel at
  `game.gd:3814-3817`. Site cancel had no refund hook (X1 C11).

### FIXED — item 1: affordability helper + pre-charge gate

- `game.gd:3671` `build_cost(player, sid, pos) -> Dictionary` — resolves the
  generic `"mine"` with `resolve_mine_sid`, guards unknown sids via
  `Data.BUILDINGS.get(...)`, then applies the **identical** escalation formula
  and skip-list the old inline block used. `cnt` counts `buildings_of(player)`
  with its default `only_finished = true`, so the count is byte-for-byte the
  same as the removed inline code.
- `game.gd:3690` `can_afford(player, sid, pos) -> bool` — bounds-checks
  `player`, rejects unknown sids, then `Data.can_pay(player.res, build_cost(...))`.
- `game.gd:3734-3738` — `place_building` now computes `esc_cost` once from
  `build_cost`, checks `can_afford` **before** `pay_cost`, and returns `{}`
  (no site spawned, no resources spent) on failure. The original
  `pay_cost` guard is retained as a second line of defence.

### FIXED — item 2: zero-builder refusal (human only)

- `game.gd:3722-3732` — inside `place_building`, when `send == true`, count
  builders that are Dictionaries, alive, of the right player and `sid ==
  "peasant"`. Zero valid builders → `_say_human(player, "Select at least one
  peasant to build.")` and `return {}` **before** cost payment and spawn.
- No auto-assignment of idle peasants was added (ruling 3). AI calls pass
  `send=false` (`ai.gd:461`, `:474`) so the guard is skipped entirely; AI
  placement behaviour is unchanged. Selftest/uitest callers pass a real
  peasant (`selftest.gd:225,272,439,697`, `uitest.gd:166`).

### FIXED — item 3: capture re-arms default rally

- `game.gd:2070-2072` — new `_default_rally(e)` returns
  `e.pos + Vector2(0, float(e.get("block_r", e.def.radius)) + 2.0)`.
- `game.gd:2093` — `_on_building_finished` now calls the helper (same value).
- `game.gd:5430-5434` — after `e.erase("rally")` on capture, re-set it from
  `_default_rally(e)` when `e.def.has("trains")`. This restores both the spawn
  exit point (`game.gd:5281`) and the world rally flag.

### FIXED — item 4: site cancel/refund

- `game.gd:3744` — `b["paid_cost"] = esc_cost.duplicate()` records exactly what
  the site cost at placement (escalation at that moment), so refund stays
  faithful even if escalation would differ later.
- `game.gd:4219-4237` — `SITE_REFUND_UNWORKED := 1.0`,
  `SITE_REFUND_WORKED := 0.5`, and `cancel_build_site(e) -> bool`:
  refuses dead / non-building / finished entities and invalid players; uses
  stored `paid_cost` (falls back to `build_cost`) and calls
  `Data.refund(players[pi].res, paid, pct)`. **Unworked site (`progress <= 0`)
  → full `1.0` refund; worked site → `0.5` partial.** No kill is performed by
  the helper.
- `game.gd:4242` — `cmd_delete` calls `cancel_build_site(e)` before `_kill`,
  so Del on your own unfinished site now refunds automatically. Finished
  buildings still refund nothing (donor demolition behaviour).
- **Partial-refund rule (documented as required):** 0.5 is a port-side
  inference, not donor-byte verified. Coordinator ruling 7 only fixed the
  unworked case at 1.0; the constant is named and exposed so it can be tuned
  in one place.

## Exact diff (W3-1 hunks only)

```diff
--- a/app/scripts/game.gd
+++ b/app/scripts/game.gd
@@ -2065,6 +2065,11 @@ func spawn(...)
+	# W3-1: shared default rally for trainers, used both on completion and after a
+	# capture (X1 C10) so _on_building_finished is not the only place that sets it.
+func _default_rally(e: Dictionary) -> Vector2:
+	return e.pos + Vector2(0, float(e.get("block_r", e.def.radius)) + 2.0)
+
 func _on_building_finished(e: Dictionary) -> void:
@@ -2085,7 +2090,7 @@
 	if e.def.has("trains"):
-		e["rally"] = e.pos + Vector2(0, float(e.get("block_r", e.def.radius)) + 2.0)
+		e["rally"] = _default_rally(e)
@@ (after can_place, before place_building)
+	# W3-1: single source of truth for the cost place_building actually charges.
+	# Mirrors the old inline escalation exactly: resolve the generic "mine" first,
+	# skip walls/gates/mines, then pow(3,cnt) for a town hall or pow(1.5,cnt) for
+	# every other sid. `cnt` counts FINISHED buildings only, matching the default
+	# of buildings_of(player) (only_finished = true).
+func build_cost(player: int, sid: String, pos: Vector2) -> Dictionary:
+	var rsid := resolve_mine_sid(sid, pos)
+	var def: Dictionary = Data.BUILDINGS.get(rsid, {})
+	if def.is_empty():
+		return {}
+	var mult := 1.0
+	if not rsid.begins_with("mine_") and rsid != "wal" and rsid != "gat":
+		var cnt := 0
+		for b in buildings_of(player):
+			if b.sid == rsid:
+				cnt += 1
+		mult = pow(3.0, cnt) if rsid == "cen" else pow(1.5, cnt)
+	var cost := {}
+	for k in def.cost:
+		cost[k] = int(round(float(def.cost[k]) * mult))
+	return cost
+
+	# W3-1: upfront affordability gate used by the sim and exposed for W3-2's HUD.
+	# True only when the player can pay the ESCALATED cost at this spot.
+func can_afford(player: int, sid: String, pos: Vector2) -> bool:
+	if player < 0 or player >= players.size():
+		return false
+	var rsid := resolve_mine_sid(sid, pos)
+	if not Data.BUILDINGS.has(rsid):
+		return false
+	return Data.can_pay(players[player].res, build_cost(player, sid, pos))
+
@@ -3658,20 +3715,33 @@ func place_building(...)
-	var mult := 1.0
-	if not sid.begins_with("mine_") and sid != "wal" and sid != "gat":
-		var cnt := 0
-		for b in buildings_of(player):
-			if b.sid == sid:
-				cnt += 1
-		mult = pow(3.0, cnt) if sid == "cen" else pow(1.5, cnt)
-	var esc_cost := {}
-	for k in def.cost:
-		esc_cost[k] = int(round(float(def.cost[k]) * mult))
+	# W3-1 / X1 C5: a human site with no builder is an orphan that can never
+	# finish. Refuse it up front; do NOT auto-assign idle peasants. AI calls
+	# pass send=false and issue their own build orders, so they are untouched.
+	if send:
+		var n_builders := 0
+		for u in builders:
+			if not (u is Dictionary) or bool(u.get("dead", false)):
+				continue
+			if int(u.get("player", -1)) != player or str(u.get("sid", "")) != "peasant":
+				continue
+			n_builders += 1
+		if n_builders == 0:
+			_say_human(player, "Select at least one peasant to build.")
+			return {}
+	# W3-1 / WAVE3_DECISIONS 4: gate on the same escalated cost the sim charges,
+	# before the site exists and before pay_cost touches the player's resources.
+	var esc_cost: Dictionary = build_cost(player, sid, pos)
+	if not can_afford(player, sid, pos):
+		_say_human(player, "Not enough resources.")
+		return {}
 	if not pay_cost(player, esc_cost):
 		_say_human(player, "Not enough resources.")
 		return {}
 	var b := spawn(sid, player, pos, false)
+	b["paid_cost"] = esc_cost.duplicate()
@@ -4134,11 +4212,34 @@
+	# W3-1 / X1 C11: cancelling an unfinished site refunds what was actually paid.
+	# Full refund (1.0) while no builder has worked the site; once work started the
+	# refund is PARTIAL (SITE_REFUND_WORKED = 0.5) to represent consumed material.
+	# Finished buildings are never refunded (donor demolition gives no refund).
+const SITE_REFUND_UNWORKED := 1.0
+const SITE_REFUND_WORKED := 0.5
+
+func cancel_build_site(e: Dictionary) -> bool:
+	if e.dead or e.kind != "building" or bool(e.get("finished", false)):
+		return false
+	var pi: int = int(e.get("player", -1))
+	if pi < 0 or pi >= players.size():
+		return false
+	var paid: Dictionary = e.get("paid_cost", {})
+	if paid.is_empty():
+		paid = build_cost(pi, str(e.sid), e.pos)
+	if paid.is_empty():
+		return false
+	var pct: float = SITE_REFUND_UNWORKED if float(e.get("progress", 0.0)) <= 0.0 else SITE_REFUND_WORKED
+	Data.refund(players[pi].res, paid, pct)
+	return true
+
 # Delete: remove your own selected units/buildings ...
 func cmd_delete(e: Dictionary) -> void:
 	if e.dead or e.player != 0:
 		return
+	cancel_build_site(e)
@@ -5316,9 +5422,19 @@ func _tick_building(...)
 				e["queue"] = []
 				e["research"] = null
 				e.erase("rally")
+				# W3-1 / X1 C10: _on_building_finished will not run again for a
+				# captured trainer, so re-arm the same default rally here.
+				if e.def.has("trains"):
+					e["rally"] = _default_rally(e)
```

## Backup

- `inbox/backup/game.gd.bak-W31` — `Copy-Item app\scripts\game.gd inbox\backup\game.gd.bak-W31`
  (220 579 bytes, created 2026-11-24 09:54:49 local, taken **before** the first edit).
- No other file was written by this agent. `input_controller.gd`, `hud.gd`,
  `world.gd`, `data.gd`, `ai.gd` and the test files were **read only**.

## Runner job + result (one targeted test, no full selftest)

```
python app\tools\godot_runner.py run --id w31-build-rules --timeout 200 -- \
  --headless --path app --script res://tests/building_block_test.gd
```

- Result JSON: `app/.godot_queue/results/00001275.json`
  → `ticket=1275`, `id=w31-build-rules`, `exit=0`, `status=ok`,
  `wait=0.0012s`, `run=8.282s`, `timeout=200s`.
- stdout: `app/.godot_queue/results/00001275_w31-build-rules/stdout.txt`
  → `building_block_test: 6/6 checks passed` (all six PASS lines; stderr empty).
- Manifest check: `app/tests/manifest.json:6-12` maps `t_build_flow` →
  `res://tests/building_block_test.gd`, so the requested script path is valid.

**Honest caveat:** `building_block_test.gd` is the *building collision/block*
regression test (X1's `t_build_flow`), **not** a dedicated build-rule test. It
does **not** call `build_cost`, `can_afford`, `cancel_build_site`, the
zero-builder guard or the capture rally path. What it does prove is that the
edited `game.gd` parses, preloads, constructs, spawns, moves units and kills
buildings cleanly — i.e. no syntax/load regression — and that the existing
build-blocking behaviour is intact. There is no in-repo test that directly
exercises the new helpers, and ownership (`game.gd` only) forbade adding one.
The new logic is therefore **code-verified but not individually
runtime-verified**; treat direct verification as an open item for the
coordinator's final gate.

## Hand-off API for W3-2 (`input_controller.gd` / `hud.gd`)

Callable on the `C3Game` instance (`game`), all deterministic and side-effect
free except where noted:

| Call | Returns | Use |
|---|---|---|
| `game.build_cost(p, sid, pos)` | `Dictionary` of escalated cost, keys = `Data.RES_NAMES` (`food,wood,stone,gold,iron,coal`); `{}` for unknown sid | Show the real price in build button / ghost hint instead of `def.cost` |
| `game.can_afford(p, sid, pos)` | `bool` | Gate `_on_build_pick`, hotkey branch, ghost entry and click commit |
| `game.cancel_build_site(e)` | `bool` | Refund an unfinished site; returns `false` for finished/dead/foreign entities. `cmd_delete` already calls it, so a Del key needs no extra call. |
| `game.SITE_REFUND_UNWORKED` / `game.SITE_REFUND_WORKED` | `1.0` / `0.5` | Hint text for cancel confirmation |

Notes for the wiring:

1. Pass the **raw** build sid (including the `"mine"` pseudo-sid) and the cursor
   position. `resolve_mine_sid` is applied inside both helpers, so no
   pre-resolution is needed. All three mine types share the same cost, so a
   nearest-deposit choice cannot change the displayed number.
2. `can_afford` is **resources only**. Keep `game.can_place(p, sid, pos)` for
   terrain/collision and keep the research gates that `place_building` still
   enforces: `bar18` needs `game.players[p].get("has18c", false)` and
   `multicannon` needs `game.players[p].get("has_multi", false)`. Full ghost
   predicate: `chk.ok and game.can_afford(...) and research_ok and has_peasant`.
3. Builder presence for the UI: count `game.get_selected()` entries with
   `sid == "peasant"`, `not dead`, `player == p`. The sim now refuses with
   `"Select at least one peasant to build."`; echo that on the hint line.
4. Refusal strings from the sim are `"Not enough resources."` and
   `"Select at least one peasant to build."` (both via `_say_human`, so they
   appear for human slots only).
5. Sites carry `paid_cost` (the actual charged cost). If W3-2 adds a cancel
   confirmation hint, read that dict for the exact refund amount.
6. `build_cost` counts **finished** buildings only, matching the existing
   charge. Consecutive sites placed in the same tick before one finishes will
   each be priced at the base cost — the HUD will show the same, so it stays
   consistent with the sim.

## Determinism note

- No `randi`, `randf`, `rand_range`, seed, clock or timer added anywhere.
- Escalation uses the same `pow()` and the same `buildings_of(player)` iteration
  order as the removed inline code; `Data.can_pay`/`Data.refund` use
  `int(round())` exactly as the pre-existing training-cancel path
  (`game.gd:3814-3817`). No new random draw can perturb default-seed traces.
- `_default_rally` is pure arithmetic from `e.pos` and `e.get("block_r", ...)`,
  so both completion and capture produce the identical value.
- The only state newly written is `b["paid_cost"]` on an unaffordable-free
   placed site and the re-armed `e["rally"]` on a captured trainer; neither
  enters any RNG stream.

## NOT-DONE / open questions

1. **No dedicated runtime test for the four new behaviours** (see honest
   caveat). Recommend a coordinator-owned `t_build_rules` test:
   - `build_cost(0,"cen",pos)` base 700 wood → 2100 after one finished `cen`;
   - `place_building(0,"hou",pos,true,[])` returns `{}` and leaves resources
     untouched; same with `send=false` still spawns;
   - zero-resource `place_building(0,"hou",pos,true,[peasant])` returns `{}`;
   - `cancel_build_site(site)` returns full refund at `progress==0`, half at
     `progress>0`; `cmd_delete(site)` routes through it;
   - capture a trainer → `e.has("rally")` and value equals `_default_rally(e)`.
2. **0.5 partial refund** is an inference; ruling 7 only specified 1.0 for
   unworked sites. Confirm the worked-site percentage.
3. **Builder death mid-build** can still orphan a site (the peasant sent at
   placement may die en route). W3-2 must expose the cancel key for recovery;
   auto-reassigning idle peasants was explicitly ruled out.
4. **Shift-queue** with the same selected peasant for several sites can leave
   earlier sites stalled because `cmd_build` overwrites one order. Out of
   scope for this ticket; flag for coordinator if reproducible.
5. Research-gated sids (`bar18`, `multicannon`) are outside `can_afford` by
   design; if W3-2 wants a single predicate, add a small wrapper on their side
   rather than widening this helper.
6. Line numbers drifted during the wave (other workers' uncommitted changes to
   this same file are present in the working tree); re-grep by symbol before
   any follow-up patch.
