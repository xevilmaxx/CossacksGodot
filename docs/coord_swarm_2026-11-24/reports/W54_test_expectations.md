---
owner: W5-4
date: 2026-11-24
wave: 5
scope: "Close the two test-owner expectation residuals. Edits confined to app/tests/t_hud_fidelity.gd (2 lines) and this report; app/scripts/uitest.gd inspected but deliberately UNCHANGED. No hud.gd / ai.gd / main.gd edits; no assertion weakened or made position-agnostic; Godot only via app/tools/godot_runner.py."
method: "All prior claims treated UNDONE until re-observed in current source. Re-read W23_hud_fidelity.md, W32_building_ux.md, WAVE5_CHARTER.md, then the current shipped HUD source and both owned test files with file:line evidence before touching anything. Backups taken before the single edit. Five runner jobs submitted (one HUD, four uitest); result JSONs / stdout / stderr read back."
output: "One 2-line test edit + this report."
backups: ["inbox/backup/t_hud_fidelity.gd.bak-W54 (6869 bytes)", "inbox/backup/uitest.gd.bak-W54 (13478 bytes)"]
runner_jobs: ["1291 w54-hud OK (15.79 s, 6/6 checks)", "1292 w54-uitest TIMED-OUT (245.61 s, exit -9)", "1302 w54-uitest2 FAILED transient startup (8.03 s, empty stderr)", "1306 w54-uitest3 FAILED on concurrent ai.gd parse errors (372.18 s, exit 1)"]
status: "Residual 1 FIXED+VERIFIED; Residual 2 NO-CHANGE/CLOSED by inspection. HUD test gate green 1291. Fresh uitest gate VERIFICATION-BLOCKED-BY-ENVIRONMENT; pre-wave-5 settled gate 1290 was green 17/17."
---

# W5-4 — test-owner expectation residuals — 2026-11-24

## Verification policy / path note

The task text names `app/tests/uitest.gd`, but a repo-wide glob finds exactly one
`uitest.gd`: **`app/scripts/uitest.gd`** (the path used by the W2-3 report,
`uitest.gd:304-307`, and by the runner command `--ui-test app/uitest.json`).
That real file is the one backed up, inspected and left unchanged. No Godot
process was launched outside `godot_runner.py`.

## Residual 1 — `[N]` → `(N)` worker-count expectation — **FIXED + VERIFIED**

### Evidence the shipped HUD emits `(N)`

Current `app/scripts/hud.gd:1235-1245`, re-read this session:

```gdscript
1235  for i in 6:
1236      var rname: String = str(Data.RES_NAMES[i])
1237      var stock: int = int(game.players[0].res[i])
1238      var stock_s: String = RES_STOCK_CAP_TEXT if stock > RES_STOCK_CAP else str(stock)
1242      var consume: int = int(upkeep_workers.get(rname, 0)) if i >= 3 else 0
1243      var net: int = workers - consume
1244      var net_s: String = "(%d-%d)" % [workers, consume] if consume > 0 else "(%d)" % workers
1245      var rt := "%s  %s" % [stock_s, net_s]
```

This is the W2-3 donor-style readout; the old `"%d [%d]"` form is gone. Confirmed
at runtime by job 1291: `res_labels=6 texts=["0  (0)", "0  (1)", "0  (0)", ...]`.

### Exact minimal diff (backup → current `app/tests/t_hud_fidelity.gd`)

```diff
--- inbox/backup/t_hud_fidelity.gd.bak-W54
+++ app/tests/t_hud_fidelity.gd
@@ -139,12 +139,12 @@ func _run() -> void:
 	var wood_txt := str(labels[wood_i].text) if wood_i >= 0 and labels.size() > wood_i else ""
 	var all_bracketed := true
 	for l in labels:
-		if not str(l.text).contains("["):
+		if not str(l.text).contains("("):
 			all_bracketed = false
 	var counts = hud.worker_counts
 	var wood_workers := int(counts.get("wood", 0)) if counts is Dictionary else 0
 	check("worker_counts_brackets",
-		all_bracketed and wood_workers >= 1 and wood_txt.contains("[%d]" % wood_workers),
+		all_bracketed and wood_workers >= 1 and wood_txt.contains("(%d)" % wood_workers),
 		"wood_workers=%d wood_line='%s' all_bracketed=%s worker_counts=%s" % [
 			wood_workers, wood_txt, str(all_bracketed), str(counts)])
```

Exactly two literal expectation strings changed (`:142`, `:147`). No condition,
threshold, check name, detail string or behaviour was altered. Coincidental
note: coordinator commit `ba83ebce` (11:31:44) has since folded this change into
HEAD, so `git diff` is now empty; the backup-vs-file diff above is the
authoritative record of W5-4's edit.

### Intent preserved (net vs gross, divisor, deficits)

* **Net vs gross** — wood is `RES_NAMES` index 1, so `hud.gd:1242` gives
  `consume = 0` and `:1244` produces the pure `"(%d)" % workers` form. Line
  `:1241` reads the same gross gatherer count from `worker_counts` that W2-3
  left as `counts`. The assertion still requires BOTH `wood_workers >= 1` AND
  the rendered number to equal `worker_counts["wood"]`; a wrong count or a
  swapped net/gross term still fails. Job 1291 observed `wood_workers=1`,
  `wood_line='0  (1)'` — exact match.
* **Divisor** — the donor `32/100/250` upkeep conversion only feeds
  `upkeep_workers` for `i >= 3` (gold/iron/coal) at `hud.gd:1242`; wood has no
  upkeep term. Switching the delimiter character cannot mask a divisor error in
  the wood line. This test never asserted divisor arithmetic directly; that
  coverage is unchanged, not reduced.
* **All six lines** — `all_bracketed` still requires every one of the six
  resource labels to contain the count delimiter; it is now `(` and job 1291
  reports `all_bracketed=true`.
* **Deficits** — the `red_deficit_colouring` step (`t_hud_fidelity.gd:163-174`)
  was not touched and passed in 1291 with
  `res_deficit=[true, false, false, true, false, false]`, `food_red=true`,
  `gold_red=true`. Idle-warning text/colour and score steps also unchanged and
  passing.

### Runner evidence — job 1291 `w54-hud`

Command: `python app\tools\godot_runner.py run --id w54-hud --timeout 180 -- --headless --path app --script res://tests/t_hud_fidelity.gd`

Runner: ticket 1291, `wait 0.00 s`, `run 15.79 s`, `exit 0`, status **ok**.
stdout includes:

```
  PASS  worker_counts_brackets - wood_workers=1 wood_line='0  (1)' all_bracketed=true worker_counts={ "food": 0, "wood": 1, ... }
```

`app/tests/results/t_hud_fidelity.json` (written by the test itself):
`"passed": true`, **6/6 checks passed** (`six_resource_labels`,
`worker_counts_brackets`, `idle_warning_text`, `idle_warning_colour`,
`red_deficit_colouring`, `score_text`). stderr 0 bytes.

## Residual 2 — minimap position/size expectation — **NO-CHANGE / CLOSED-NO-CHANGE** (option a)

### Evidence the HUD still ships bottom-left 200 px

Current `app/scripts/hud.gd`, re-read this session:

| Site | Current source | Meaning |
|---|---|---|
| `:1344-1346` | `custom_minimum_size = Vector2(200, 200)`; meta `uimw/uimh = 200.0` | 200 px, not 240 |
| `:1349-1352` | `minimap_rect.anchor_left = 0.0`, `anchor_right = 0.0`, `anchor_top = 1.0`, `anchor_bottom = 1.0` | bottom-**left** anchored |
| `:1353-1365` | parent `panel`: `:1356 anchor_left = 0.0`, `:1357 anchor_right = 0.0`, `:1360-1363 offset_left = 4`, `offset_top = -212`, `offset_right = 234`, `offset_bottom = 0` | left-edge panel |
| `:256` | comment `bottom strip, partitioned left->right: minimap \| selection \| orders` | layout partition unchanged |
| `:260` | `var mm := minf(_ms(200.0), ui_vp.x * 0.20)` | 200 px in scaling path |
| `:273-277` | `minimap_panel.offset_left = _ms(4.0)` | minimap starts at left edge |
| `:475` | `cmd_panel.anchor_left = 1.0` | command panel still owns the right edge |

`grep -n "240" app/scripts/hud.gd` → **no matches**. No later wave moved the
minimap; W2-3's item-4 `NOT-DONE` is still the current state.

The assertion under test (`app/scripts/uitest.gd:304-307`) is:

```gdscript
304  func _s_minimap_frustum(steps: Array) -> void:
305      var par: Control = hud.minimap_rect.get_parent()
306      var ok: bool = hud.minimap_rect != null and par != null and par.anchor_left == 0.0
307      steps.append({"step": "minimap_frustum", "passed": ok, "detail": "minimap bottom-left: %s" % ("yes" if ok else "no")})
```

`par` is the `panel` created at `hud.gd:1353`, whose `anchor_left` is `0.0`
(`hud.gd:1356`). The assertion therefore exactly matches shipped behaviour.
Per the task's option (a): **left as-is**, no position-agnostic weakening, no
`hud.gd` edit. `inbox/backup/uitest.gd.bak-W54` is byte-identical to the current
file (`git diff --no-index` empty).

**Scope boundary.** This closes the *test-owner expectation* residual only. The
underlying donor-fidelity gap (W2-3 item 4: donor minimap is bottom-right 240 px
per `initminimap.inc`) remains OPEN and belongs to the `hud.gd` owner; moving it
would also require re-partitioning `hud.gd:263-279` so the minimap does not
overlap the right-edge command panel. Out of W5-4 ownership.

### Runner evidence — uitest gate (blocked in this wave)

| Job | Command / timeout | Result |
|---|---|---|
| **1290** `coord-final-all-uitest` (pre-wave-5 settled gate) | `--ui-test app/uitest.json`, runner 240 s | `exit 0`, `run 118.59 s`, status **ok**; stdout ends `ui-test report: .../app/uitest.json`; `app/uitest.json` has `"passed": true`, **17/17 steps, 0 failed** (mtime 10:51:11, still on disk) |
| **1292** `w54-uitest` | `--timeout 240` | created 11:10:27; hard-killed after `run 245.61 s`, `exit -9`, status **timed-out**. stdout: Godot banner + two `sprites: 116 sets loaded (sids=173)` lines only (the duplicate is normal — also in 1290); no `ui-test report:`; stderr `[runner] KILLED after 240.0s`. `app/uitest.json` NOT rewritten (`ai.gd` was edited by W5-1 at 11:12:39, mid-run) |
| **1302** `w54-uitest2` | `--timeout 240` | `run 8.03 s`, `exit 1`, status **failed**; stdout Godot banner only, stderr 0 bytes, report not rewritten — transient startup-failure signature (cf. W2-3 job 1266), not an assertion failure |
| **1306** `w54-uitest3` | runner `--timeout 400` + app `--timeout 360` | `run 372.18 s`, `exit 1`; stderr: `SCRIPT ERROR: Parse Error: Cannot infer the type of "uid2" variable ... res://scripts/ai.gd:609`, `... "food_budget" ... ai.gd:625`, `Compile Error: Failed to compile depended scripts ... res://scripts/main.gd:0`, `Failed to load script "res://scripts/main.gd"`, `Invalid call. Nonexistent function 'new' in base 'GDScript' ... _create_ai_brains (res://scripts/main.gd:660)`, `watchdog: wall-clock limit reached, forced exit`. Those are concurrent W5-1 edits to `ai.gd` (mtime 11:12:39), not W5-4 files; by report time `ai.gd:609/625` already read as explicitly typed (`var uid2: String`, `var food_budget: float`), i.e. their owner fixed them. No further re-submission after the coordinator's stop instruction. |

**Verdict: VERIFICATION-BLOCKED-BY-ENVIRONMENT** for a *fresh* uitest gate in
wave 5. The NO-CHANGE conclusion itself rests on (1) direct current-source
inspection of `hud.gd` showing the assertion still matches shipped HUD, and
(2) the pre-wave-5 settled gate 1290 passing 17/17 on the same unchanged
`uitest.gd`. None of the three in-wave uitest attempts produced an assertion
failure; they were a hard timeout, an empty-stderr startup failure, and a
third-party parse error. The coordinator's final gate should re-run uitest
after W5-1/W5-2 source churn has settled.

## Open questions

1. **Cosmetic staleness.** The check name `worker_counts_brackets` and local
   `all_bracketed` are retained verbatim so the result-JSON key stays stable
   for downstream tooling and the diff remains exactly two lines. They now
   describe parentheses loosely ("brackets"). Rename in a later cleanup if
   desired; not done here because the directive was "update ONLY those
   expectations".
2. **Donor minimap fidelity remains open** (W2-3 item 4, Q4): bottom-right
   240 px still needs an owner with `hud.gd` access plus the bottom-strip
   re-partition. This report does not claim that gap is closed.
3. **Fresh uitest gate pending.** Job 1290 proves the settled state green
   (17/17), but wave 5's concurrent edits prevented an in-wave reproduction;
   re-run at the coordinator's final gate.
4. **Path discrepancy** in the task text (`app/tests/uitest.gd` vs actual
   `app/scripts/uitest.gd`) — resolved by glob; real file untouched.
