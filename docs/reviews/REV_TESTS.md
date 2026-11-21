---
title: REV-2 — Small-test review (T1–T15)
updated: 2026-11-21
status: review complete
reviewer: REV-2 (read-only test/doc desk)
---

# 🔬 REV-2 — Small feature-test review

> [!NOTE]
> Scope: the 15 new `app/tests/t_*.gd` files plus the 6 legacy standalone tests and the
> framework (`manifest.json`, `test_all.py`, runner results). Read-only; no Godot, no test
> edits. Governed by **D-15** (one feature per file + registry + aggregator) and **D-16**
> (runner starvation fixes). Framework rules are from `app/tests/README.md` §"Small-test
> framework" and `_template_test.gd`.

## Verdicts

| Test | Owner | Verdict | Evidence | Required fix |
|---|---|---|---|---|
| t_upgrades | test-T1 | **WARN** | Job 85 `skipped (serving=86)`; retry job 103 exit 1 at **parse time** (`Could not preload res://scripts/game.gd`, t_upgrades.gd:15; `:=` errors :92–103 cascade). 6 checks use real `Data.UPGRADES`/`effective_damage()`/`apply_upgrade()`; baseline FAIL documented :6–7. | Re-run after game.gd is green + runner un-wedged; confirm `t_upgrades.json` written. |
| t_roster_scotland | test-T2 | **WARN** | Job 91 `skipped (serving=92)` — never executed. 6 checks use real `NATIONS`/`NATION_UNITS`/`resolve_sid`/`_bld_key`/`_anim_key`; baseline FAIL documented :8–12. | Re-run; confirm result JSON. |
| t_squads | test-T3 | **WARN** | Job 92 `skipped (serving=94)` — never executed. 5 checks use real `squad_form`/`formation_targets`/`cmd_replenish`/`_formation_*`; partial-impl gap documented :7–9. | Re-run; confirm result JSON. |
| t_multi_ai | test-T4 | **WARN** | Job 89 `skipped (serving=93)` — never executed. 6 checks use real `new_player()`/`spawn()`/`AI.tick()`; baseline FAIL documented :8–10. | Re-run; confirm result JSON. |
| t_teams | test-T5 | **WARN** | Job 97 exit 1 at **parse time** (game.gd preload, t_teams.gd:25). 5 checks use real `new_player`/`enemies_in_radius`/`cmd_attack`/`_check_victory`; baseline FAIL documented :16–18. | Re-run after game.gd green. |
| t_smoke_fx | test-T6 | **WARN** | Job 100 exit 1 at **parse time** (preload :15, `:=` :89–171). 6 checks use real `add_fx`/`sync`/projectiles; arrow-trail expected FAIL documented :136–140. | Re-run after game.gd green. |
| t_water | test-T7 | **WARN** | Job 101 exit 1 at **parse time** (preload :23/:131). 5 checks on `terrain`/`BLK_WATER`/`world.variants`; baseline FAIL documented :11–15. | Re-run after game.gd green. |
| t_weather | test-T8 | **BLOCK** | Job 99 exit 1; **genuine independent parse bug** — `PackedByteArray` has no `.hash()` at `app/tests/t_weather.gd:145`, `:149`, `:156` (`summer_img.get_data().hash()` etc.). Test can never compile even when game.gd is fixed. Other 6 checks are real API calls; baseline FAIL documented :4–8. | Replace `.get_data().hash()` with global `hash(img.get_data())` or a pixel-based digest; then re-run after game.gd green. |
| t_hud_fidelity | test-T9 | **WARN** | Job 94 exit 1 at **parse time** (preload :17). 6 checks use real `C3HUD.bind`/`hud_report`/`_process`; baseline FAIL documented :8–9. | Re-run after game.gd green. |
| t_anim_metrics | test-T10 | **WARN** | Job 93 `skipped (serving=94)` — never executed. 5 data-only checks on the two anim index JSONs (no game.gd dependency). | Re-run; confirm result JSON. |
| t_naval | test-T11 | **WARN** | Job 90 `skipped (serving=94)` — never executed. 5 asset checks on `yacht_walk/hull.png` + `index.json`; declared asset test that should pass on current data. | Re-run; confirm result JSON. |
| t_mass_army | test-T12 | **WARN** | Job 98 exit 1 at **parse time** (preload :15, `:=` :107–175). 6 checks incl. real perf metric; partial-feature baseline documented :7. | Re-run after game.gd green. |
| t_map_variety | test-T13 | **WARN** | Job 96 exit 1 at **parse time** (preload :20; `:=` :187,190,191,223). 5 checks use real mapgen state/`Marshalls`; baseline FAIL documented :11–12. | Re-run after game.gd green. |
| t_capture | test-T14 | **WARN** | Job 102 exit 1 at **parse time** (preload :21, `:=` :83–124). 6 checks use real `spawn`/`cmd_guard`/`nearest_mine`/`train_unit`; baseline FAIL documented :12–13. | Re-run after game.gd green. |
| t_audio_events | test-T15 | **APPROVE** | Job 95 **executed** (run 1.86 s, exit 1). Only result JSON on disk: `app/tests/results/t_audio_events.json` — 1 pass / 4 fail (names_for, walk_sound, chop, nation themes), matching the documented baseline :2–4. Real-API assertions (`audio.gd` `names_for`/`walk_sound`/`has`, on-disk `.ogg` scan, `main.gd` chop branch). | None; re-run when P-12/P-13 land. |

Framework rules check (all 15): own file, `extends SceneTree`, headless, exactly one
`call_deferred("quit", …)`, no bare `quit()` (grep: only comment text), result JSON written
by code with `{id,passed,checks}`, 5–6 concrete assertions, pending-feature baseline FAIL
documented in the header, unique manifest id/`pending` status/timeout. No copy-paste
placeholders found; assertions match the claimed feature in every file. Minor: t_audio_events'
`check()` prints no PASS/FAIL line (cosmetic).

## Framework health

- **Registry (D-15):** 20 entries / 20 unique ids — 5 legacy `ready` (no `owner` field) + 15 new
  `pending` (owners `test-T1`…`test-T15`, timeouts 60/90/120 s). All 15 new tests are registered
  with unique ids and feature labels. ✅
- **Result JSON coverage:** **1/15** (`t_audio_events.json`). The other 14 wrote nothing — 6 were
  `skipped` by the runner wedge, 8 failed at parse time. ❌
- **Runner (D-16):** waits of **177–348 s** against 90–120 s timeouts; 6 t-* jobs `skipped` with
  `error: "ticket N was skipped (serving=M)"`. Preload of `res://scripts/game.gd` failed for all
  8 that ran — `app/scripts/game.gd` is currently modified (` M`), consistent with a mid-edit
  feature build (P-23/P-24) during the queue drain. This is an infra/timing artifact; the
  downstream `:=`-inference errors cascade from the unresolved preload. Re-run required.
- **test_all.py:** `--list` / `--only` / `--include-pending` work and it delegates to
  `godot_runner.py` (respects D-03). Usability gaps: (1) default run selects only `status=ready`,
  so plain `python test_all.py` **never exercises the 15 new tests** without
  `--include-pending`; (2) `run_one()` never deletes a stale `<id>.json` before a run, so a
  test that fails to start can be scored from an old file (false-green risk); (3) windowed tests
  get `--timeout` appended twice (lines 42 and 46) — cosmetic/confusing.

## Key decisions cited

- **D-15** — one feature per test file + `manifest.json` + `test_all.py`; all 15 new tests
  conform structurally, so the framework design itself is sound.
- **D-16** — runner starvation fixes; the skip/timed-out telemetry in this batch shows the
  wedge still affected the t-* jobs (queued behind long selftest runs), so result coverage —
  not test authoring — is the dominant failure mode.

---

## REPORT (for coordinator)

- **Tests reviewed:** 15 new t-* tests + 6 legacy standalone tests (grep-verified no bare
  `quit()`) + framework files.
- **Verdict counts:** APPROVE **1**, WARN **13**, BLOCK **1**.
- **BLOCKs:** `app/tests/t_weather.gd:145`, `:149`, `:156` — `PackedByteArray` has no `.hash()`
  (genuine compile error, independent of the game.gd preload issue).
- **Files created:** `docs/reviews/REV_TESTS.md` (this file). No test files modified.
- **Open questions:**
  1. Is the game.gd preload break transient (concurrent P-23/P-24 edit; file is ` M` now), or
     is there a persistent parse error that must be fixed before any re-run?
  2. After the wedge clears, should QA re-run all 15 with `--include-pending` and require a
     result JSON for each before the tests can be signed off?
  3. Should `test_all.py` delete stale result JSONs and/or include pending tests by default,
     to prevent false-green scoring?
