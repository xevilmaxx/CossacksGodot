---
id: S02-SPEED-IMPL
ticket: "S02-IMPL (WAVE S integration; corrected owner — G04 misrouted and told to ignore)"
title: "S02 — x8/x16/x32/x64 speed dropdown APPLIED (3 owned files; no Godot, no runner)"
owner: "S02 implementation subagent — EXCLUSIVE owner of hud.gd, main.gd, t_hud_layout.gd"
date: 2026-11-25
status: IMPLEMENTED__AWAITING_G04_GATES__NO_GODOT__NO_RUNNER_JOB
scope: "Exactly 4 repo files written: the 3 owned sources below + this report. Backups created BEFORE the first edit. app/** untouched (0 changed paths). No P12 HUD-cost hunks applied. No acc/sim-loop behaviour change."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROX]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
proposal: docs/terrain_swarm_2026-11-25/reports/S02_speed_fix.md
audit: docs/terrain_swarm_2026-11-25/reports/S01_speed_audit.md
---

# S02 — implementation landing report

## 0. Authority and what was NOT done

- **OBSERVED:** dispatch grants EXCLUSIVE ownership of `variant3d/scripts/hud.gd`,
  `variant3d/scripts/main.gd`, `variant3d/tests/t_hud_layout.gd`. G04 will not touch them;
  G04 was misrouted the ticket and has been told to ignore it.
- **OBSERVED:** S01 (`reports/S01_speed_audit.md`), S02 proposal
  (`reports/S02_speed_fix.md`), `CHARTER.md` and `WAVE_G_CHARTER.md` were read in full
  before any edit. The applied hunks are **exactly S02 §3.1** (the primary patch, which
  includes x8 as the owner-baseline bridge). §3.2 ("no new x8") was **not** used.
- **OBSERVED:** **No Godot process, no runner job, no capture, no test execution and no
  FPS/frame-time measurement** by this agent (`WAVE_G_CHARTER.md:31` — only G04 runs jobs).
  All gate results in §5 are **UNVERIFIED expectations for G04**, not observations.
- **OBSERVED:** P12's HUD-cost proposal (`P12_hud_fix_proposal.md`) is **NOT applied here**.
  Only the S02 dropdown/cap hunks were applied; the P12 redraw/poll paths in `hud.gd`
  remain byte-unchanged.
- **OBSERVED:** **acc behaviour preserved.** S02 §7 optional hardening
  (`acc = minf(acc, step * 2.0)` after the while loop) was deliberately **NOT applied**.
  The `steps < 64` cap, `Data.FPS = 32.0` step, tick order and `world.sync(dt)` path are
  untouched.
- **OBSERVED:** `app/**` (2D) untouched — `git status --short -- app` returned 0 paths.
  `config.gd`, `uitest.gd`, `data.gd` and `hud3d_adapter.gd` were **not** edited.
- **OBSERVED:** no donor-parity claim. `x16/x32/x64` are **PORT APPROX / owner-directive**,
  with no donor citation and no donor GPU A/B frame. The misleading "donor speed set"
  wording was softened to "pause + port speeds", matching S02 §2.

## 1. Requirement delivered

Final dropdown labels: `II, 1x, 2x, 4x, 8x, 16x, 32x, 64x`
Final metadata: `[0.0, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0]` (float; asserted with
0.001 tolerance at `t_hud_layout.gd:430`)
Default selection: **index 1 = 1x** (unchanged).

**DERIVED:** the pre-existing `_mkoption()` (`hud.gd:490-501`), `_speed_index()`
(`:597-603`), `_on_speed_idx()` (`:605-608`), `_on_speed()` (`:646-649`) and
`refresh_speed()` (`:635-644`) are multiplier-agnostic, so no other HUD change was needed.

## 2. Backups — taken BEFORE the first edit

`CHARTER.md:66` / `WAVE_G_CHARTER.md:87` require `inbox/backup/<name>.bak-<TICKET>`.
No `.bak-S02` destination existed before this work (checked). The three copies were made
first, then SHA-256 hashed. Backup hash == original pre-edit hash for all three.

| File | Pre-edit SHA-256 | Backup | Backup SHA-256 | Bytes |
|---|---|---|---|---:|
| `variant3d/scripts/hud.gd` | `D6BBC866B0443ACE0EA9A89B71750CAA7836415428EF38AD7C40B80013EA7CDF` | `inbox/backup/hud.gd.bak-S02` | `D6BBC866B0443ACE0EA9A89B71750CAA7836415428EF38AD7C40B80013EA7CDF` | 87161 |
| `variant3d/scripts/main.gd` | `72CC28D444CA9A6214B3FF7C17A9D0440140AA246B4F10FD9DB649293D3F7E17` | `inbox/backup/main.gd.bak-S02` | `72CC28D444CA9A6214B3FF7C17A9D0440140AA246B4F10FD9DB649293D3F7E17` | 86073 |
| `variant3d/tests/t_hud_layout.gd` | `586E8DC0C234377ADD17FB52386527F8840A606BAF7F310F40E8FCEA5F4FACDF` | `inbox/backup/t_hud_layout.gd.bak-S02` | `586E8DC0C234377ADD17FB52386527F8840A606BAF7F310F40E8FCEA5F4FACDF` | 26872 |

Post-edit hashes (for audit):

| File | Post-edit SHA-256 | Bytes |
|---|---|---:|
| `variant3d/scripts/hud.gd` | `7748CC9507A35AF313C62C2D89BFF1BD8C9D0E1851E9837AEC6D0F97FCE0C319` | 87380 |
| `variant3d/scripts/main.gd` | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | 86133 |
| `variant3d/tests/t_hud_layout.gd` | `CB50EC1B5AA9E6BF5C8C36B0A65E59ED9EC5DCBBFCF6FE076E28A01A2261B80B` | 27002 |

Line endings preserved as LF in all three files (verified byte-level; no CRLF conversion).

**Rollback** (restores exact pre-patch bytes): copy each `.bak-S02` back over its target.

## 3. Exact diff applied

```diff
diff --git a/variant3d/scripts/hud.gd b/variant3d/scripts/hud.gd
index c9c2839e..e0151501 100644
--- a/variant3d/scripts/hud.gd
+++ b/variant3d/scripts/hud.gd
@@ -437,11 +437,14 @@ func _build_top() -> void:
 	status_label.clip_text = true
 	top_bar.add_child(status_label)
 	# game speed + menu, like the original's top-right controls. UI-TOPBAR-01:
-	# the four speed buttons become ONE OptionButton (donor speeds + pause);
+	# the four legacy speed buttons become ONE OptionButton (pause + port speeds);
 	# labels/tooltips/hotkeys and the speed_label readout stay as before.
 	var sep2 := VSeparator.new()
 	top_bar.add_child(sep2)
-	speed_menu = _mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]], 1)
+	# S02 (owner directive): x8/x16/x32/x64 extend the old 1x/2x/4x set.
+	# x16/x32/x64 are PORT APPROX — NOT donor-verified; no donor GPU A/B exists.
+	speed_menu = _mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0],
+		["8x", 8.0], ["16x", 16.0], ["32x", 32.0], ["64x", 64.0]], 1)
 	speed_menu.tooltip_text = "Game speed (Space pauses)"
 	speed_menu.item_selected.connect(_on_speed_idx)
 	top_bar.add_child(speed_menu)
diff --git a/variant3d/scripts/main.gd b/variant3d/scripts/main.gd
index fdab1507..30262b23 100644
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd
@@ -359,7 +359,7 @@ func _apply_menu_cfg(cfg: Dictionary) -> void:
 	Data.CAPTURE_ENABLED = Data.CAPTURE_MODE == "default"
 	# Game speed is wired only when the command line did not force one.
 	if speed == 1.0:
-		speed = clampf(float(Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)), 0.1, 8.0)
+		speed = clampf(float(Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)), 0.1, 64.0)  # S02: uniform cap
 	autosave_acc = 0.0
 
 	Data.START_OPTION = str(cfg.get("startingunits", cfg.get("start_option", "default")))
@@ -719,7 +719,7 @@ func _menu_nation_name(sid: String, i: int) -> String:
 	return "Player %d" % (i + 1)
 
 func set_speed(s: float) -> void:
-	speed = clampf(s, 0.0, 8.0)
+	speed = clampf(s, 0.0, 64.0)  # S02: dropdown now offers up to x64
 	if hud != null and hud.has_method("refresh_speed"):
 		hud.refresh_speed(speed, game.paused if game != null else false)
 
diff --git a/variant3d/tests/t_hud_layout.gd b/variant3d/tests/t_hud_layout.gd
index 5ec8468d..8a17ee36 100644
--- a/variant3d/tests/t_hud_layout.gd
+++ b/variant3d/tests/t_hud_layout.gd
@@ -57,9 +57,10 @@ const PNG_FLAGS := ["--png-1024x576", "--png-1280x720", "--png-1920x1080"]
 
 # Pixel slack only for float/container rounding, never for a real overflow.
 const EPS := 2.0
-# hud.gd:444 / :495-498 — donor speed set plus pause, item metadata in seconds.
-const SPEED_LABELS := ["II", "1x", "2x", "4x"]
-const SPEED_META := [0.0, 1.0, 2.0, 4.0]
+# hud.gd:444 / :495-498 — pause + port speeds, item metadata in seconds.
+# S02: x8/x16/x32/x64 are OWNER-DIRECTIVE extensions; x16/x32/x64 UNVERIFIED vs donor.
+const SPEED_LABELS := ["II", "1x", "2x", "4x", "8x", "16x", "32x", "64x"]
+const SPEED_META := [0.0, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0]
 # hud.gd:124-130 (RES_TOOLTIPS) + data.gd:25 (six resources in this order).
 # HUD-LAYOUT-REPAIR-01: gold/iron/coal now read "produced at", matching the
 # current donor-cited literals at hud.gd:128-130 (hud.gd itself is NOT edited).
```

### Hunk rationale (DERIVED)

- **`hud.gd:444`** — x8 is added as the bridge, then x16/x32/x64. `selected` index
  remains `1`, so the startup default is still **1x**. The two new comment lines shift
  later `hud.gd` line numbers by **+2** (relevant to any future P12 rebase).
- **`main.gd:362`** — raised `0.1..8.0` → `0.1..64.0`. S02 §3.1 hunk notes and A7 mark
  this **behaviour-neutral today**: `Data.DONOR_GAME_SPEED` holds only `0.5/1.0/2.0/4.0`
  (`data.gd:385`), so nothing reaches the old ceiling. Included for a uniform cap.
  `--fast = 8.0` (`main.gd:1351`) is intentionally unchanged.
- **`main.gd:722`** — raised `0.0..8.0` → `0.0..64.0`; mandatory, otherwise every new
  option silently collapses to x8. `set_speed(0.0)` (freeze atoms) and
  `set_speed(2.0)` (`uitest.gd:276-278`) are unaffected.
- **`t_hud_layout.gd:60-62`** — **spec update, not a weakening.** The exact-equality
  assertions at `:424-434` are byte-unchanged, `SPEED_LABELS` and `SPEED_META` now
  describe the real UI list, and the **check count stays 62**. No threshold, assertion,
  fixture or `expected_pre_fix_failure` was removed or relaxed.
- **acc/sim loop (`main.gd:1614-1631`)** — **byte-unchanged**. S02 §7 hardening is
  explicitly excluded. Pre-existing `steps < 64` = 2.0 sim-s/frame remains the safety
  valve; new labels are **target rates**, not guaranteed wall-clock rates.

## 4. Honesty labels

- **OBSERVED:** the four edited source regions match S02 §3.1 verbatim; backups precede
  edits and hash-match the pre-edit originals; `app/**` has zero changed paths.
- **DERIVED:** default 1x and `--fast` x8 are unchanged; donor ids still resolve to ≤4;
  accumulator saturation only bound above x8, which is untouched today.
- **UNVERIFIED:** all gate results in §5. No Godot run, capture, FPS number or timing
  measurement exists for this landing. The ×16/×32/×64 rates are targets, not measured.
- **PORT APPROX:** x16/x32/x64 are owner-directive extensions, not donor-verified.
- No synthetic dither/noise, no invented donor constants, no donor-parity claim.

## 5. Gate list for G04 (owner of the sole Godot/runner lane)

All entries are **UNVERIFIED until G04 re-runs them with unique ids**. S02-IMPL submits
no jobs. A single failure means stop and re-derive — do not loosen an assertion.

| # | Gate | Required result | Why this patch should not break it | Status |
|---:|---|---|---|---|
| 1 | variant **uitest** (`variant3d/uitest.json`) | **17/17**, `passed:true`; `speed_pause` detail still "game speed set to 2x: yes" | `uitest.gd:274-280` calls `set_speed(2.0)`; only the *upper* clamp moved. No dropdown assertion in uitest. | UNVERIFIED — G04 |
| 2 | **t_hud_layout** (`t_hud_layout.gd`) | **62/62 checks**, 3 recorded SKIP_CAPTURE per headless precedent / 3 real PNGs when windowed, 0 unclipped offenders | `speed_options_*` / `speed_option_metadata_*` (`:424-434`) pass only with the updated spec constants; check count unchanged; `_layout_top()` otherwise byte-untouched. | UNVERIFIED — G04 |
| 3 | variant **selftest** (`variant3d/selftest.json`) | **29/29**, `passed:true`, `SCRIPT ERROR == 0` | `hud.hud_report()` path untouched; no new runtime call in `_process`; acc/sim loop unchanged. | UNVERIFIED — G04 |
| 4 | **t_render_mode** / 3D minimap seam | `result=PASS`, `seam_missing=false` | No adapter or minimap code touched. | UNVERIFIED — G04 |
| 5 | **No UI overflow at 1024 / 1280 / 1920** | `top_panel_right_in_viewport_*` and `no_unclipped_control_outside_viewport_*` green at all three sizes; capture images nonblank | DERIVED: only longer option *text* (≤3 chars per item); `_ms(menu_w)` sizing (`hud.gd:588`), `status_label` `SIZE_EXPAND_FILL` + `clip_text` (`:436-437`) and `top_panel.clip_contents` (`:402`) unchanged. Confirm with the three windowed PNGs. | UNVERIFIED — G04 |
| 6 | **S03 speed atom** (per `reports/S03_speed_qa.md`) + windowed capture verifying each new speed actually changes sim rate | atom result PASS; x1/x2/x4/x8/x16/x32/x64 each measurably advance `game.time_s` at the expected multiplier within the 2.0 sim-s/frame ceiling caveat; `speed_label` reads `N x` and dropdown mirrors index 0..7 | New metadata flows through `_speed_index`/`_on_speed_idx`/`refresh_speed`; no app/2D change. G04/P09 owns measurement; low-fps throttling at x16+ is a documented target-vs-actual caveat, not a gate failure by itself. | UNVERIFIED — G04 + S03 owner |
| 7 | **config.defaults** (`visual_tuning_test.gd:51-58`) | PASS: `unit_scale=1.25`, `show_centroids=false`, `units_opaque=false` | `config.gd` untouched; no speed key enters `config.defaults`. | UNVERIFIED — G04 |
| 8 | **t_menu_roster** | `main.speed == 2.0` for donor "fast" | Config clamp ceiling change is behaviour-neutral (`data.gd:385` max 4.0); `--fast = 8.0` unchanged. | UNVERIFIED — G04 |
| 9 | **2D `app/**`** | zero edits | Diff has no `app/` paths. | OBSERVED — no edit by this agent |

## 6. Availability

Implementation is complete and backed up. This agent stays available for COORD's
follow-up (e.g. re-deriving the hud hunk if another lane lands first, or adjusting after
G04's gate results). No further edits are pending from S02-IMPL.

*End of S02 implementation report — 3 owned files patched, 3 backups taken, zero Godot/runner jobs submitted.*
