---
id: S02-SPEED-FIX
ticket: S02 (WAVE S / speed options)
title: "S02 — ready-to-apply x16/x32/x64 dropdown patch (PROPOSAL ONLY, do not apply yet)"
owner: S02 read-only subagent
date: 2026-11-25
status: READ_ONLY_PROPOSAL__NO_CODE_EDITS__NO_RUNNER_JOB__NO_GODOT
scope: "Exactly one repo file written: this report. hud.gd, main.gd, t_hud_layout.gd, config.gd, uitest.gd and app/** were READ ONLY; no backup was created, no patch applied, no Godot process or runner job submitted."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROX]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# S02 — x16 / x32 / x64 UI speed options (exact hunks, not landed)

## 0. Authority and what was NOT done

- `WAVE_G_CHARTER.md:31,67` — **only G04 runs Godot / runner jobs.** S02 ran none and
  submits none. `WAVE_G_CHARTER.md:143-155` is the Wave S assignment: S02 is a
  ready-to-apply proposal with exact file:line hunks; "read-only/proposal only while G04
  runs gates".
- `CHARTER.md:55-69` — observed / derived / inferred / UNVERIFIED separated; **no test
  weakening**; disjoint ownership; backups before edits; Windows `python` (not `python3`),
  PowerShell `;` (not `&&`).
- `reports/S01_speed_audit.md` had **not landed** at the time of this read (glob
  `**/S01*` empty). The source files below were read directly instead, as instructed.
- **No code edit, no backup, no test run, no capture, no FPS claim, no donor-parity claim.**
  `git status --short` at read time showed `hud.gd`, `main.gd` and `t_hud_layout.gd` clean;
  the working tree already carried unrelated B03/B05/B01/B02/B04/B06 edits, which this
  patch does not touch.

## 1. Speed pipeline — OBSERVED (current tree, file:line)

| # | file:line | Observed fact |
|---:|---|---|
| A1 | `variant3d/scripts/hud.gd:444` | `speed_menu = _mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]], 1)` — **the dropdown tops out at x4, not x8.** Default selected index `1` = 1x. |
| A2 | `hud.gd:490-501` | `_mkoption()` stores each item's float as metadata; `uimw=72`, `uimh=30`, font 14. |
| A3 | `hud.gd:597-608` | `_speed_index()` matches metadata within `0.01`; `_on_speed_idx()` emits the float; `refresh_speed():635-644` mirrors external changes without a feedback loop. All are multiplier-agnostic — **no edit needed**. |
| A4 | `hud.gd:646-649` | `_on_speed()` → `speed_cb.call(sp)`; readout `"%.0fx" % sp` at `:637` already formats 2-digit speeds. **No edit needed**. |
| A5 | `main.gd:626-632` and `:1145-1151` (two construction paths) | `speed_cb`: `s <= 0` pauses, else `set_speed(s)`. **No edit needed**. |
| A6 | `main.gd:721-724` | `set_speed(s)` → `speed = clampf(s, 0.0, 8.0)`. **This is the hard cap that would silently reduce x16/x32/x64 to x8.** Must be raised. |
| A7 | `main.gd:360-362` | Config-derived speed (`Data.DONOR_GAME_SPEED`, values `0.5/1/2/4` at `data.gd:385`) clamped `0.1..8.0`. Behaviour-neutral to raise; consistency only. |
| A8 | `main.gd:1350-1353` | `--fast` sets `speed = 8.0`; `--speed` uses `maxf(0.1, …)` with no upper bound. Both stay unchanged — **x8 stays a default**. |
| A9 | `main.gd:1614-1621` | `dt = minf(dt, 0.25)`, `acc += dt * speed`, `step = 1/Data.FPS`, `while acc >= step and steps < 64`. `data.gd:32` `FPS = 32.0` → step `0.03125 s`; 64 steps = 2.0 sim-s per rendered frame. |
| A10 | `variant3d/tests/t_hud_layout.gd:60-62,412-441` | `SPEED_LABELS := ["II","1x","2x","4x"]`, `SPEED_META := [0.0,1.0,2.0,4.0]`; exact-equality assertions at **three** viewport sizes. Adding options without updating these constants fails 6 checks. |
| A11 | `variant3d/scripts/uitest.gd:274-280` | `speed_pause` calls `main.set_speed(2.0)` and checks `main.speed == 2.0`; raising only the upper clamp leaves it green. |
| A12 | `variant3d/tests/visual_tuning_test.gd:49-58` | `config.defaults` checks only `display.unit_scale/show_centroids/units_opaque`; no speed config is read. No config change is required or made. |
| A13 | `app/scripts/hud.gd:357-371` | The 2D app has its own x1/x2/x4 speed buttons. **Deliberately out of scope** (`CHARTER.md:129`: 2D `app/` untouched). |

### Critical discrepancy — the "x8" premise

`WAVE_G_CHARTER.md:145-146` states the dropdown "currently tops out at x8" and the owner
says *"x8 for ui speeds add x16 speeds and maybe even x32 and x64"*. **OBSERVED source
(A1) has no x8 option.** The only x8 in the tree is `--fast` (A8) and the two clamp
constants (A6/A7). `S01` has not landed to adjudicate this.

**S02's decision (primary patch below):** add `8x` *as the bridge* together with
`16x/32x/64x`, so the resulting set is `II, 1x, 2x, 4x, 8x, 16x, 32x, 64x` — i.e. the
owner's stated "x1..x8" baseline plus the three requested higher rates. All pre-existing
options and the `1x` default are byte-unchanged. If COORD rules that no new x8 entry is
wanted, §3.2 gives the one-line alternative; COORD must choose before application.

## 2. Derivations and honesty labels

- **DERIVED:** with the ×64 option selected, `set_speed(64.0)` stores `64.0` (after the
  raised clamp), `_speed_index(64.0)` → index 7, and the readout reads `64x`. The existing
  64-step/frame guard (A9) caps throughput at 2.0 sim-s per rendered frame: at 32 render
  fps that is exactly ×64; at lower render fps the *effective* rate is throttled below the
  label. This is a pre-existing safety valve, not a new failure mode, but it means the
  new labels are **target rates**, not guaranteed wall-clock rates.
- **DERIVED / RISK:** when `dt * speed > 2.0` (e.g. ×16+ with `dt` near the 0.25 hitch
  clamp), `acc` is not drained by the 64 steps and can stay positive across frames.
  Optional hardening is in §7; it is **not** in the primary patch.
- **PORT APPROX / NOT DONOR-VERIFIED:** `x16`, `x32` and `x64` are **owner-directive
  extensions only**. No donor citation, donor screenshot, donor config value or donor GPU
  A/B exists for them. The pre-existing `hud.gd:440` / `t_hud_layout.gd:60` wording "donor
  speed set" is deliberately softened in the patch so it does not become a false donor
  claim. Donor-documented speed controls are hotkeys (`Shift ×5`, `Ctrl unlimited`,
  `CHARTER.md:112`), not these dropdown labels.
- **UNVERIFIED:** every FPS / frame-time / "feels faster" statement. No capture, telemetry,
  runner job or Godot process was produced by S02. "No UI overflow at 1024/1280/1920" in
  §6 is an **expected gate result to be re-run by G04**, not a verified observation.
- **No test weakening:** §3.1's test hunk changes a test's *expected values* to the new owner-specified
  set; the exact-equality assertions remain, and the check count stays 62. No threshold,
  assertion or fixture is deleted or relaxed.

## 3. Ready-to-apply unified diff (single patch, 3 files)

Derived from the current working tree (LF as read). Apply with `git apply --recount` so
minor line drift from other lanes is tolerated. **Do not apply until COORD grants the
owners in §5 and G04's gate run is accounted for.**

### 3.1 Primary patch — includes x8 as owner-baseline bridge

```diff
--- a/variant3d/scripts/hud.gd
+++ b/variant3d/scripts/hud.gd
@@ -439,8 +439,10 @@
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
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd
@@ -360,3 +360,3 @@
 	# Game speed is wired only when the command line did not force one.
 	if speed == 1.0:
-		speed = clampf(float(Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)), 0.1, 8.0)
+		speed = clampf(float(Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)), 0.1, 64.0)  # S02: uniform cap
@@ -721,4 +721,4 @@
 func set_speed(s: float) -> void:
-	speed = clampf(s, 0.0, 8.0)
+	speed = clampf(s, 0.0, 64.0)  # S02: dropdown now offers up to x64
 	if hud != null and hud.has_method("refresh_speed"):
 		hud.refresh_speed(speed, game.paused if game != null else false)
--- a/variant3d/tests/t_hud_layout.gd
+++ b/variant3d/tests/t_hud_layout.gd
@@ -59,5 +59,6 @@
 const EPS := 2.0
-# hud.gd:444 / :495-498 — donor speed set plus pause, item metadata in seconds.
-const SPEED_LABELS := ["II", "1x", "2x", "4x"]
-const SPEED_META := [0.0, 1.0, 2.0, 4.0]
+# hud.gd:444 / :495-498 — pause + port speeds, item metadata in seconds.
+# S02: x8/x16/x32/x64 are OWNER-DIRECTIVE extensions; x16/x32/x64 UNVERIFIED vs donor.
+const SPEED_LABELS := ["II", "1x", "2x", "4x", "8x", "16x", "32x", "64x"]
+const SPEED_META := [0.0, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0]
 # hud.gd:124-130 (RES_TOOLTIPS) + data.gd:25 (six resources in this order).
```

**Hunk notes (derived):**
- `hud.gd`: the selected index stays `1`, so the default is still `1x`; `_speed_index()`,
  `_on_speed_idx()`, `refresh_speed()` and `_layout_top()` are byte-untouched. The two new
  comment lines shift later `hud.gd` line numbers by **+2** — relevant to P12's rebase
  (§5), not to this patch's own context.
- `main.gd:360-362` is behaviour-neutral today: `Data.DONOR_GAME_SPEED` only holds
  `0.5/1.0/2.0/4.0` (`data.gd:385`), so nothing reaches the old 8.0 ceiling. It is included
  so the cap is uniform. `main.gd:1351` `--fast = 8.0` is intentionally unchanged.
- `main.gd:721-724`: only the upper bound moves; `set_speed(0.0)` (used by several tests to
  freeze the sim) still works, and `uitest.gd:276-278`'s `set_speed(2.0)` is unaffected.
- `t_hud_layout.gd`: this is a **spec update**, not a weakening — exact equality over the
  full list and the float-tolerance loop (`:424-434`) remain; the check count is unchanged.

### 3.2 Alternative if COORD rules "no new x8"

Replace the two added `hud.gd` array lines with:

```diff
-	speed_menu = _mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]], 1)
+	speed_menu = _mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0],
+		["16x", 16.0], ["32x", 32.0], ["64x", 64.0]], 1)
```

and use `SPEED_LABELS := ["II","1x","2x","4x","16x","32x","64x"]` /
`SPEED_META := [0.0,1.0,2.0,4.0,16.0,32.0,64.0]` in the test hunk. Raising the `main.gd`
caps is still required. **Do not mix the two variants.**

### 3.3 Files deliberately NOT in the diff

`config.gd` (no speed key is read by the dropdown; `config.defaults` stays green),
`uitest.gd` (no expectation change needed), `app/scripts/hud.gd` (2D untouched), `data.gd`
(`DONOR_GAME_SPEED` is donor evidence — do not invent x16/x32/x64 donor values),
`hud3d_adapter.gd` (P12's file).

## 4. Backup / application / rollback (Windows)

`CHARTER.md:66` and `WAVE_G_CHARTER.md:87` require `inbox/backup/<name>.bak-<TICKET>`
**before** the first edit. No `*.bak-S02` destination existed at read time. **Do not run
any of this until §5 grants land.**

1. Verify the targets match the files this diff was derived from (read-only):
   ```powershell
   Get-FileHash -Algorithm SHA256 "variant3d\scripts\hud.gd"
   Get-FileHash -Algorithm SHA256 "variant3d\scripts\main.gd"
   Get-FileHash -Algorithm SHA256 "variant3d\tests\t_hud_layout.gd"
   ```
2. Take the three backups **before** editing, then hash them and record all six hashes
   plus byte counts in the landing report:
   ```powershell
   Copy-Item -LiteralPath "variant3d\scripts\hud.gd" -Destination "inbox\backup\hud.gd.bak-S02" -Force
   Copy-Item -LiteralPath "variant3d\scripts\main.gd" -Destination "inbox\backup\main.gd.bak-S02" -Force
   Copy-Item -LiteralPath "variant3d\tests\t_hud_layout.gd" -Destination "inbox\backup\t_hud_layout.gd.bak-S02" -Force
   Get-FileHash -Algorithm SHA256 "inbox\backup\hud.gd.bak-S02"
   Get-FileHash -Algorithm SHA256 "inbox\backup\main.gd.bak-S02"
   Get-FileHash -Algorithm SHA256 "inbox\backup\t_hud_layout.gd.bak-S02"
   ```
   If P12 lands in `hud.gd` first, the `.bak-S02` copy captures P12's bytes and the
   `hud.gd` hunk must be re-derived from the new file — do **not** hand-force it.
3. Save §3.1 (or §3.2, never both) to a patch file **outside** the repo, e.g. under
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\s02\`, then:
   ```powershell
   git apply --recount --check <patch-file>
   git apply --recount <patch-file>
   ```
   A failed check means **stop and re-read**; never hand-force a hunk.
4. All Godot verification (parse-only checks, selftest, uitest, `t_hud_layout`,
   windowed PNGs) must be submitted by **G04 only**, with unique ids. S02 submits none.
5. Rollback restores the exact pre-patch bytes:
   ```powershell
   Copy-Item -LiteralPath "inbox\backup\hud.gd.bak-S02" -Destination "variant3d\scripts\hud.gd" -Force
   Copy-Item -LiteralPath "inbox\backup\main.gd.bak-S02" -Destination "variant3d\scripts\main.gd" -Force
   Copy-Item -LiteralPath "inbox\backup\t_hud_layout.gd.bak-S02" -Destination "variant3d\tests\t_hud_layout.gd" -Force
   ```

## 5. Owner-file grant needed before application

- **`hud.gd` is contested.** `WAVE_G_CHARTER.md:154-155` explicitly says "`hud.gd` is also
  P12's proposed file — COORD grants one owner after G04 finishes; no cross-touch."
  `reports/P12_hud_fix_proposal.md:19-22,88-95` claims `hud.gd` + `hud3d_adapter.gd`
  exclusively and requires `.bak-P12`. P12's hunks touch `hud.gd:89-94,174,218,273,
  1445-1523,1611,1667-1695`; S02 touches only `:439-447`. **No textual overlap**, but the
  charter grants *one owner per file*, so COORD must either (a) grant `hud.gd` to S02 and
  have that owner apply/rebase P12's hunks too, or (b) grant it to P12 and fold S02's
  hunk into P12's single application. S02 did not touch `hud3d_adapter.gd`.
- **`main.gd`**: historically LOAD-ASYNC-01 / V7-50 ownership (`t_hud_layout.gd:6`,
  `WAVE_G_CHARTER.md:22`). COORD must grant it for the two cap hunks.
- **`t_hud_layout.gd`**: its header (`:3-6`) grants that file only to its own lane.
  The spec-constant hunk needs a separate COORD grant; it is a deliberate spec update,
  not a weakening (§2).
- **`app/scripts/hud.gd` (2D)**: **not granted, not edited** — `CHARTER.md:129` requires
  `app/` untouched. If the owner later wants x16/x32/x64 in 2D too, that is a new ticket
  with its own owner and its own 2D gates.
- All grants are **after G04's current gate run** (`WAVE_G_CHARTER.md:31,154-155`).

## 6. Regression list — expected results, all UNVERIFIED until re-run by G04/owner

| Gate | Required result | Why this patch must not break it | Status |
|---|---|---|---|
| variant **uitest** (`variant3d/uitest.json`) | **17/17**, `passed:true`; `speed_pause` detail still "game speed set to 2x: yes" | `uitest.gd:276-278` calls `set_speed(2.0)`; only the *upper* clamp moves (`:722`). No dropdown assertion in uitest. | **UNVERIFIED** (S02 ran no Godot) |
| **t_hud_layout** (windowed 1024×576 / 1280×720 / 1920×1080) | **62/62 checks**, 3 recorded SKIP_CAPTURE per headless precedent / 3 real PNGs when windowed, 0 unclipped offenders | `speed_options_*` / `speed_option_metadata_*` (`:424-434`) pass **only with §3.1/§3.2's expected-constant hunk**; check count unchanged. `_layout_top()` (`hud.gd:513-595`) byte-untouched. | **UNVERIFIED** |
| **No UI overflow at 1024 / 1280 / 1920** | `top_panel_right_in_viewport_*` and `no_unclipped_control_outside_viewport_*` green at all three sizes; capture images nonblank | DERIVED: only 3-item-longer labels (`8x`/`16x`/`32x`/`64x`); OptionButton text stays ≤3 chars, `custom_minimum_size` from `_ms(menu_w)` (`:588`), `status_label` has `SIZE_EXPAND_FILL` + `clip_text` (`:436-437`), `top_panel.clip_contents` (`:402`). Confirm with the three windowed PNGs. | **UNVERIFIED — gate to re-run, not a claim** |
| **config.defaults** (`visual_tuning_test.gd:51-58`) | PASS: `unit_scale=1.25`, `show_centroids=false`, `units_opaque=false` | `config.gd` untouched; no speed key enters `config.defaults`. | **UNVERIFIED** (no run) |
| variant **selftest** (`variant3d/selftest.json`) | **29/29**, `passed:true`, `SCRIPT ERROR == 0` | `hud.hud_report()` path (`hud.gd` later lines) untouched; no new runtime call in `_process`. | **UNVERIFIED** |
| **t_menu_roster** | `main.speed == 2.0` for donor "fast" still passes | Config clamp ceiling change is behaviour-neutral (`data.gd:385` max 4.0); `--fast = 8.0` unchanged. | **UNVERIFIED** |
| **t_hud_fidelity** | six non-empty labels, bracketed worker counts, deficit colours | No HUD poll/repaint path edited. | **UNVERIFIED** |
| **t_render_mode / 3D minimap seam** | `result=PASS`, `seam_missing=false` | No adapter or minimap code touched. | **UNVERIFIED** |
| 2D `app/**` | zero edits | Diff has no `app/` paths. | **OBSERVED (no edit)** |

"Every test green" is the **acceptance requirement after application**, not a result S02
asserts. A single failure means stop and re-derive, not loosen an assertion.

## 7. Optional hardening (NOT in the primary patch)

`main.gd:1614-1621` keeps un-drained `acc` when `dt * speed > 2.0`, which ×16+ can reach
on a <32 fps machine. If COORD wants a bounded backlog, grant the same `main.gd` owner and
add, immediately after the `while` loop (currently between `:1634` and `:1635`):

```gdscript
	acc = minf(acc, step * 2.0)  # S02 optional: drop >2 ticks of backlog, keep catch-up
```

This is a **sim-loop behaviour change** (DERIVED risk mitigation, UNVERIFIED impact), needs
its own gate run, and is deliberately excluded from §3.1 so the minimal patch stays
UI-and-cap-only.

## 8. Final honesty statement

- **FPS claims: UNVERIFIED.** No run, capture, telemetry or frame-time sample exists.
  "x64 is faster" is a *target rate*, not a measured result; §1/§2 make the 64-step ceiling
  explicit.
- **Donor claims:** none new. x16/x32/x64 are **PORT APPROX / owner-directive**, with no
  donor citation and no donor A/B frame; the patch removes the misleading "donor speed
  set" wording rather than extending it.
- **Observed contradiction:** the charter's "tops out at x8" is not what `hud.gd:444`
  contains; COORD must pick §3.1 or §3.2 before any edit.
- **No test weakening, no synthetic dither/noise, no invented donor constants, no gates,
  no Godot process, no code edit beyond this report.**

*End of S02 proposal — ready for COORD ownership grant; apply §3 only after G04's gate
run is settled.*
