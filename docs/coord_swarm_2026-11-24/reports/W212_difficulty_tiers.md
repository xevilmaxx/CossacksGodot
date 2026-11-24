---
owner: W2-12 (micro-builder)
ticket: R06 C1 / G-AI3 (AI difficulty tiers)
date: 2026-11-24
wave: 2 (difficulty-tier fidelity)
scope: app/scripts/config.gd + app/scripts/menu.gd ONLY (+ this report)
backups: inbox/backup/config.gd.bak-W212, inbox/backup/menu.gd.bak-W212
runner_job: 1260 (w212-menu-tier) — ok, exit 0, 11.92 s
evidence: docs/coord_swarm_2026-11-24/reports/R06_ai_behavior.md (read in full first)
donor_access: read-only latin-1 via Python; no donor binary executed
---

# W212 — donor AI difficulty tiers in `config.gd` / `menu.gd`

Method: re-read the current `config.gd`, `menu.gd`, `main.gd`, `data.gd` and
`app/tests/t_menu_roster.gd` before editing; re-read the donor literals directly
(`dmscript.global`, `progresseconomicai.inc`) with `python` latin-1 rather than
trusting recon line numbers. Nothing was assumed DONE from the board. Ownership
was respected: `game.gd` (resource cheat), `ai.gd` (W2-4) and `main.gd` were read
only. Port root below is `app/scripts/`; donor root is
`C:\Games\Cossacks 3\data\scripts\` (`DG` = `dmscript.global`,
`PE` = `units/global.inc/progresseconomicai.inc`).

## 1. Per-item status

| # | Item | Status | Donor evidence :line | Port evidence :line (post-edit unless *pre*) |
|---|---|---|---|---|
| 1 | Donor defines six lobby ids / five sim tiers; port had a 3-id whitelist and no tier constant | **FIXED** | `DG:781-786` (`none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4`), `DG:235` (`gc_MaxAIDifficultyCount=4`) | *pre* `config.gd:439` literal `["easy","normal","hard"]`; now `config.gd:19` `const AI_DIFFICULTIES` (five tiers, donor order, excludes `none` = human) used at `config.gd:465` |
| 2 | Donor-backed tier effects recorded (upgrade caps, diver counts, mine maxlevel, artillery split) | **FIXED (documented data only)** | `PE:2202-2213` (7/7 default; easy 0/0; normal 2/3), `PE:2322-2327` (divers 0/2/4/4), `PE:2349-2355` (howitzer 2..8 / mortar 8..40 when difficulty > normal; `cannon_count div 2` otherwise), `PE:3652-3658` (mine maxlevel 6 default; 2/3/4/5/5) | `config.gd:16-40` comment block + `const AI_TIER_EFFECTS` at `:34-40` (`max_level_att/def`, `divers`, `mine_maxlevel` for all five tiers); no runtime consumer yet |
| 3 | Per-slot dropdown offers `veryhard` / `impossible`, legacy order intact | **VERIFIED-ALREADY** | `DG:785-786` | `menu.gd:468-472` `_ai_items()` = `none, normal, hard, veryhard, impossible`; widget built at `menu.gd:646`; only a clarifying comment was added (`:467`) |
| 4 | Emitted per-slot `ai_difficulty` equals the picked donor id | **VERIFIED-ALREADY** | `DG:781-786` | `menu.gd:658-665` `_roster_cfg()` emits raw `diff` as `"ai_difficulty"` and the collapsed value only as the legacy `"difficulty"` key; no edit needed |
| 5 | Global Difficulty dropdowns also offer the two new tiers (additive, appended after the legacy three) | **FIXED** | `DG:783-786` | *pre* `menu.gd:696,849` hardcoded 3-item arrays; now `menu.gd:476-480` `_difficulty_items()` used at `menu.gd:706` (skirmish sidebar) and `menu.gd:859` (options screen). Default `difficulty="normal"` keeps index 1 |
| 6 | Saved-config compatibility: unknown ids still fall back to `normal`, `none` still coerced to `normal` in `PLAYER_AI_DIFFICULTY` | **FIXED (preserved)** | n/a (port-side compatibility rule) | `config.gd:461-465`: same fallback expression, only the whitelist swapped for `AI_DIFFICULTIES`; `none` is deliberately *not* in that list, so legacy behaviour is byte-identical for old files |
| 7 | Per-slot tier actually reaches the sim (`Data.PLAYER_AI_DIFFICULTY`) and changes AI behaviour | **NOT-DONE (needs other owners)** | `PE:2323-2326,3655-3658` | `main.gd:339-342` still validates only `easy/normal/hard` and reads `entry["difficulty"]`, never `entry["ai_difficulty"]`; `menu.gd:481-490` collapses the new tiers to `"hard"` for that legacy key; `data.gd:190-193` records tiers but `ai.gd` has no consumer. Exact hand-off in §4 |
| 8 | Resource cheat untouched | **VERIFIED-ALREADY (by constraint)** | donor has no free-resource tier cheat (R06 C19) | `game.gd:3824` still `Data.AI_DIFFICULTY == "hard"`; not edited (not my file). New tiers therefore get **no** cheat and **no** sim effect today — see §4/§5 |
| 9 | `ai.difficulty` config global: new ids accepted, legacy easy/hard knobs unchanged | **FIXED (acceptance) / NOT-DONE (effects)** | `PE:2205-2213,2323-2326,3654-3658` | `config.gd:530-537`: comment added at `:531-534`; code `if easy … elif hard …` unchanged. `veryhard`/`impossible` parse as valid strings but behave like `normal` until W2-4 wires `AI_TIER_EFFECTS` |

No donor-backed effect was implemented in `ai.gd`/`game.gd`: that would break the
exclusive-ownership boundary and the "additive only" instruction. The port's
observable default (`normal`) output is unchanged.

## 2. Exact diff applied

```diff
diff --git a/app/scripts/config.gd b/app/scripts/config.gd
@@ -13,6 +13,32 @@ class_name C3Config
 
 const FILE_NAME := "config.json"
 
+# R06 C1 / donor dmscript.global:781-786,235: six lobby ids
+# (none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4). "none" marks a
+# human slot, so the sim's canonical tiers are these five, in donor order.
+const AI_DIFFICULTIES := ["easy", "normal", "hard", "veryhard", "impossible"]
+
+# Donor-backed tier defaults (PE = units/global.inc/progresseconomicai.inc).
+# Documented for the W2-4 / main.gd / game.gd hand-off only: config.gd does not
+# apply them and leaves ai.gd behaviour and the game.gd resource cheat alone.
+#   easy        maxLevelAtt/Def 0/0 (PE:2205-2208), divers 0 (unset PE:2321),
+#               mine maxlevel 2 (PE:3654), cannon_count div 2 (PE:2355)
+#   normal      maxLevelAtt/Def 2/3 (PE:2209-2212), divers 0 (PE:2323),
+#               mine maxlevel 3 (PE:3655) - the unchanged port default
+#   hard        inherited 7/7 (PE:2202-2203), divers 2 (PE:2324),
+#               mine maxlevel 4 (PE:3656), howitzer 2..8 / mortar 8..40 (PE:2349-2352)
+#   veryhard    inherited 7/7, divers 4 (PE:2325), mine maxlevel 5 (PE:3657),
+#               artillery as hard
+#   impossible  inherited 7/7, divers 4 (PE:2326), mine maxlevel 5 (PE:3658),
+#               artillery as hard
+const AI_TIER_EFFECTS := {
+	"easy": {"max_level_att": 0, "max_level_def": 0, "divers": 0, "mine_maxlevel": 2},
+	"normal": {"max_level_att": 2, "max_level_def": 3, "divers": 0, "mine_maxlevel": 3},
+	"hard": {"max_level_att": 7, "max_level_def": 7, "divers": 2, "mine_maxlevel": 4},
+	"veryhard": {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5},
+	"impossible": {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5},
+}
+
 # The base values. config.json is merged over this, so a file that only
 # changes one line still works.
 const DEFAULT := {
@@ -436,7 +462,7 @@ func apply() -> void:
 	if pad is Array:
 		for v in (pad as Array):
 			var d := str(v)
-			Data.PLAYER_AI_DIFFICULTY.append(d if ["easy", "normal", "hard"].has(d) else "normal")
+			Data.PLAYER_AI_DIFFICULTY.append(d if AI_DIFFICULTIES.has(d) else "normal")
 
 	# T-MENU-ROSTER DEEP: full donor option set for saved configs. Unknown ids
 	# fall back to the donor default instead of corrupting the sim.
@@ -502,6 +528,10 @@ func apply() -> void:
 	Data.AI_ATTACK_FORCE = num("ai.attack_force", 60.0)
 	Data.AI_MAX_PEASANTS = int(num("ai.max_peasants", 14.0))
 	Data.AI_DIFFICULTY = text("ai.difficulty", "normal")
+	# Legacy port-only knobs below cover easy/hard. veryhard/impossible are now
+	# accepted ids but have no sim effect yet: consuming AI_TIER_EFFECTS above
+	# needs ai.gd (W2-4) + per-slot wiring in main.gd/game.gd. The "normal"
+	# default path is unchanged.
 	if Data.AI_DIFFICULTY == "easy":
 		Data.AI_THINK_INTERVAL *= 1.6
 		Data.AI_ATTACK_FORCE *= 0.7
diff --git a/app/scripts/menu.gd b/app/scripts/menu.gd
@@ -464,14 +464,24 @@ func _team_items() -> Array:
 
 # OWNER-SPEC (en\gui.txt:153-162, showcustomgame.inc:73-86): per-player AI
 # difficulty replaces the plain Human/Computer pick. "None" => human slot.
+# R06 C1: the last two donor tiers are appended, so legacy id order is intact.
 func _ai_items() -> Array:
 	return [{"id": "none", "name": "None"},
 		{"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"},
 		{"id": "veryhard", "name": "Very Hard"},
 		{"id": "impossible", "name": "Impossible"}]
 
-# The sim only knows easy/normal/hard globally; collapse the two hardest donor
-# tiers onto "hard" and keep the donor id alongside for config/UI fidelity.
+# Global difficulty rows mirror ConfigScript.AI_DIFFICULTIES: the legacy three
+# keep their order/indices, the two donor tiers are appended (R06 C1).
+func _difficulty_items() -> Array:
+	return [{"id": "easy", "name": "Easy"}, {"id": "normal", "name": "Normal"},
+		{"id": "hard", "name": "Hard"}, {"id": "veryhard", "name": "Very Hard"},
+		{"id": "impossible", "name": "Impossible"}]
+
+# main.gd:339-342 only accepts easy/normal/hard, so the two new donor tiers
+# collapse onto "hard" for that legacy key. The real id is emitted unchanged as
+# the roster's "ai_difficulty" key below (_roster_cfg); making the sim's
+# Data.PLAYER_AI_DIFFICULTY carry it needs the main.gd/game.gd hand-off.
 func _sim_difficulty(donor_id: String) -> String:
 	match donor_id:
 		"none": return "none"
@@ -693,7 +703,7 @@ func _show_skirmish() -> void:
 	options_body.add_child(_opt_row("Allies", [{"id": "default", "name": "Default"}, {"id": "nearby", "name": "Nearby"}], allies, func(id: String): allies = id))
 	options_body.add_child(_section_label("Rules"))
 	options_body.add_child(_opt_row("Starting", _starts(), start_option, func(id: String): start_option = id))
-	options_body.add_child(_opt_row("Difficulty", [{"id": "easy", "name": "Easy"}, {"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"}], difficulty, func(id: String): difficulty = id))
+	options_body.add_child(_opt_row("Difficulty", _difficulty_items(), difficulty, func(id: String): difficulty = id))
 	options_body.add_child(_opt_row("Balloon", _donor_items(Data.DONOR_BALLOON,
 		{"default": "Default", "no_balloons": "No Balloons", "balloons": "Balloons"}),
 		balloon, func(id: String): balloon = id))
@@ -846,7 +856,7 @@ func _on_seed_text_changed(text: String, field: LineEdit) -> void:
 
 func _show_options() -> void:
 	_clear()
-	body.add_child(_opt_row("Difficulty", [{"id": "easy", "name": "Easy"}, {"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"}], difficulty, func(id: String): difficulty = id; _save_options()))
+	body.add_child(_opt_row("Difficulty", _difficulty_items(), difficulty, func(id: String): difficulty = id; _save_options()))
 	var shb := HBoxContainer.new()
 	shb.add_theme_constant_override("separation", 10)
 	var sl := Label.new()
```

Tabs preserved. `config.gd` is CRLF in both backup and working copy; `menu.gd`
was already LF in both (the git LF→CRLF warning is pre-existing, not introduced
here). No called symbol was renamed.

## 3. Backups and verification

Backups taken **before** the first edit (verified by byte count):

* `inbox/backup/config.gd.bak-W212` — 25,379 bytes
* `inbox/backup/menu.gd.bak-W212` — 38,244 bytes

One targeted runner job only (no godot call from this agent, no full selftest):

```
python app\tools\godot_runner.py run --id w212-menu-tier --timeout 180 -- ^
  --headless --path app --script res://tests/t_menu_roster.gd
```

* Result JSON: `app/.godot_queue/results/00001260.json` — ticket `1260`, id
  `w212-menu-tier`, `status: ok`, `exit: 0`, `wait 0.0014 s`, `run 11.916 s`,
  `timeout 180.0`; stdout/stderr under
  `app/.godot_queue/results/00001260_w212-menu-tier/` (stderr empty).
* Test result: `app/tests/results/t_menu_roster.json` — `"passed": true`, all 30
  checks pass, including `per_slot_difficulty`
  (`PLAYER_AI_DIFFICULTY=["normal" x6]`), `ui_option_rows`
  (`right-column option rows=20, section headers=3`), `ui_emit_roster` and
  `ui_emit_donor_keys` (`missing donor keys: []`).
* Honest delta: `git diff app/tests/results/t_menu_roster.json` changes **only**
  `unix_ms` (`1795450907152.0` → `1795510596279.0`); every check name, detail
  and verdict is identical to the pre-edit baseline. No new assertion was added
  and no run was performed for the new tiers themselves.

## 4. Exact hand-off needed for other owners

Per-slot tiers are recorded by the menu but cannot affect the sim from my two
files alone. The chain to close, in order:

1. **`main.gd` owner — `_apply_roster_cfg` (`main.gd:322-348`):** currently
   `main.gd:339-342` reads only `entry["difficulty"]` and whitelists
   `easy/normal/hard`. Change to prefer the already-emitted donor id, e.g.
   `var mapped := str(entry.get("ai_difficulty", entry.get("difficulty", "normal")))`
   and validate against `C3ConfigScript.AI_DIFFICULTIES` (plus `"none"` if it
   must remain storable). Then `main.gd:348` publishes the real tier. Keep the
   legacy `difficulty` fallback for old configs. Optional: extend the in-game
   overlay picker at `main.gd:1088-1091` (still a 3-item literal) to the same
   five ids; `main.gd:308-309` already passes any string through.
   Until this is done, menu's `_sim_difficulty` (`menu.gd:485-490`) must keep
   collapsing `veryhard`/`impossible` to `hard` — passing the raw id through
   would be coerced to `normal` by the current whitelist and would **lower**
   difficulty.
2. **`ai.gd` owner (W2-4):** consume the tier (global `Data.AI_DIFFICULTY` and/or
   the per-slot `Data.PLAYER_AI_DIFFICULTY` once (1) lands) and apply
   `C3ConfigScript.AI_TIER_EFFECTS` from `config.gd:34-40`: diver counts
   0/0/2/4/4 (`PE:2323-2326`), mine upgrade maxlevel 3/4/5/5 for
   normal/hard/veryhard/impossible (`PE:3655-3658`), attack/defence upgrade caps
   (`PE:2202-2213`), and artillery boost for `difficulty > normal`
   (`PE:2349-2355`, howitzer `2..8` / mortar `8..40`). Do **not** change the
   default `normal` branch. The acceptance test from R06 rank 3 remains open:
   `ai.difficulty="impossible"` must yield ≥4 divers and level-5 mine upgrades.
3. **`game.gd` owner:** decide the fate of the hard-only resource cheat at
   `game.gd:3824` (R06 C19). It was deliberately left untouched; if it is kept
   as a separate flag, `veryhard`/`impossible` must not be made weaker than
   `hard` by the new tier path. Mine-upgrade caps may need a `game.gd` build/
   upgrade hook as well as `ai.gd` ordering.
4. **`data.gd` owner (only if needed):** `data.gd:190-193` documents per-slot
   tiers as "recorded only"; update that comment when (1)/(2) land. No new
   static was added here.

## 5. Determinism note

All edits are constants, comments, and a whitelist extension: no `random`,
`randi`, time source, physics or tick-order change; no new RNG draws and no
change to `DEFAULT` (`config.gd:44+`) or to the `normal` multiplier branch
(`config.gd:535-537`). Default `normal` config output and the `normal`-only
roster test are byte-identical to the baseline (§3). Newly selectable tiers are
inert until other owners consume them, so no existing golden trace changes.
Any later tier implementation should use the seeded sim RNG if donor-style
strategy randomness is added (R06 C15), never `random`.

## 6. Open questions

1. The donor's per-slot menu has `easy=0` (`DG:782`) but the port per-slot
   dropdown has `none/normal/hard/veryhard/impossible` (no `easy`); global
   dropdowns keep `easy`. Should `easy` be appended per-slot, or is the current
   asymmetry intentional ("None" = human)? Left unchanged to preserve ordering.
2. Should a per-slot `veryhard`/`impossible` override the single global
   `Data.AI_DIFFICULTY`, or only seed a per-player tier while the global knob
   stays the config-file value? R06 open question 2 is still unanswered.
3. `easy` diver count is recorded as 0 because `PE:2321` declares an
   uninitialised `numdiver` with no case branch; donor-inferred, not a literal.
4. `AI_TIER_EFFECTS` omits the artillery numbers (comment only at
   `config.gd:26,31`); W2-4 may want them as explicit keys when wiring
   `PE:2349-2355`.
5. No direct test exists for the new ids: the one permitted runner job exercises
   only the existing `normal` assertions. A follow-up fixture should set a slot
   to `impossible`, assert `Data.PLAYER_AI_DIFFICULTY` carries it **after**
   hand-off step 1, then assert ≥4 divers / mine maxlevel 5 after step 2.
