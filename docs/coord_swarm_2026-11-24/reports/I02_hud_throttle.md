---
owner: I2
date: 2026-11-24
item: recon P2 Top-5 #1 (P02_render_hotpaths.md, claim 1)
status: done
---

# I02 — HUD status counter throttle

## What was throttled

`app/scripts/hud.gd::_process()` recomputed `game.unit_count(0) + game.queue_count(0)`
**every frame** (O(live units) + a full `buildings_of()` array allocation/scan via
`queue_count`) even though `status_label.text` is dirty-guarded and rarely changes.
The expensive pair of calls now runs on the existing ~0.5 s `eco_t` cadence.

Status text composition is otherwise unchanged: `unit_count`/`queue_count` feed a
cached scalar, while `farm_cap`, `score` and `paused` are still read live each
frame into the composed string, so those fields remain frame-accurate; only the
unit/queue number is batched.

## Exact diff (file:line numbers refer to the post-edit file)

- `app/scripts/hud.gd:23-25` — new cache member with explanatory comment:
  `var _cached_ucount := 0` (placed beside `eco_t`, sharing its cadence).
- `app/scripts/hud.gd:1072` — inside the existing `if eco_t <= 0.0:` block,
  immediately after `_recompute_eco()`, added:
  `_cached_ucount = game.unit_count(0) + game.queue_count(0)`.
- `app/scripts/hud.gd:1100` — replaced
  `var ucount := game.unit_count(0) + game.queue_count(0)`
  with
  `var ucount := _cached_ucount  # throttled on eco_t (~0.5 s); other fields stay live`.

No called symbol was renamed. No HUD layout, colours, timers, dirty guards or
other features touched. Indentation is tabs, matching surrounding style.

## Backup

`inbox/backup/hud.gd.bak-I2-HUDCOUNT` (copied from `app/scripts/hud.gd` before edits).

## Runner job + result

- Command: `python app\tools\godot_runner.py run --id i2-hud-throttle --timeout 180 -- --headless --path app --script res://tests/t_hud_fidelity.gd`
- Runner ticket: **1234**, id **i2-hud-throttle** — START, END **ok** (run 12.54 s).
- Result file `app/tests/results/t_hud_fidelity.json`: `"passed": true`, 6/6 checks.
  `score_text` detail: `status='units 8/100    score 1160    '` (cached ucount = 8, correct).

## Max staleness / correctness

- Unit + queue count in the status line is at most **0.5 s** stale (one `eco_t`
  period), meeting the "correct within 0.5 s" requirement. Initial value is
  populated on the first `_process()` tick because `eco_t` starts at `0.0`.
- `score`, `farm_cap` and `PAUSED` text remain **instant** (read/composed every
  frame); the dirty-text guard at `:1105-1107` is unchanged and still suppresses
  identical-string assignments.

## Visual / functional risk

Low. Visible text is byte-identical for a given game state; only the refresh
instant of the unit/queue integer moves by up to 0.5 s (imperceptible for a
diagnostic readout). The test drives `_process_hud()` with `eco_t = 0.0`, so it
exercises the recompute path and passes. No colour, layout or timing semantics
changed.

## Determinism note

Deterministic. The cache is updated only from a fixed dt-driven timer (`eco_t`,
reset to `0.5`), never from wall-clock or frame-count assumptions. With fixed
`dt` (as in the test) recompute cadence is identical run-to-run. No randomness
and no new global state beyond one private scalar on the HUD instance.

## Open questions

- None blocking. The existing `refresh_speed()` pause trigger only touches
  `speed_label`, not the status line; no change needed because `paused` is still
  composed live each frame. If a future change gates status composition behind
  a timer, that trigger would need to also invalidate `_cached_ucount`/status.
