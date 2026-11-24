# Wave 2 — fix all key corrections (owner directive 2026-11-24)

**Owner directive:** "spawn agents to fix all key corrections, claim everything is
undone." Therefore: **no prior DONE/PASS/claim is trusted.** Every worker verifies
the current source itself (`observed` with file:line) before editing; if a gap is
already closed, report CLOSED with evidence and do NOT duplicate work.

Gates from `SWARM_OPS.md` §3 + §5b-QUALITY remain binding at every depth:
one Godot at a time via `godot_runner.py`; disjoint file ownership; backup before
edit; evidence before edits; `observed`/`derived`/`inferred`; minimal diffs;
no donor redistribution; targeted test per fix, coordinator runs the final gate.

## Ownership map (disjoint — no file assigned twice)

| ID | Owned files | Fix scope (from `GAPS.md`) |
|---|---|---|
| W2-1 | `app/scripts/game.gd` | Capture-mode inversion, who may capture, gold-shortage desertion/ship-stop, capture gunfire block, capture cancels queue/upgrade, artillery capture rate |
| W2-2 | `app/scripts/data.gd` | Grapeshot range 175→450, wrong upgrade values (firepower/wheellock/bayonet/Mathematics), add naval upgrades |
| W2-3 | `app/scripts/hud.gd`, `app/scripts/input_controller.gd` | HUD fidelity: net workers, iron/coal deficits, cap, tooltips, clickable indicators, capture % divisor, minimap position |
| W2-4 | `app/scripts/ai.gd` | Wave cadence (8 s cooldown), miner floor during famine, tier behaviour |
| W2-5 | `app/scripts/world.gd` | Post-bake chunk scheduling early-out; weather/snow/cloud art if assets exist |
| W2-6 | `app/scripts/main.gd`, `app/scripts/selftest.gd` | T3 Scenario B snapshot restore for <30 s subsets; CLI frame-budget flag; per-step wall_ms |
| W2-7 | `app/scripts/audio.gd` | 2/5 ambient beds → donor-equivalent ambient set |
| W2-8 | `app/tools/scan_map.py` | 28.5 s scan: duplicate `json.load`, BFS ring loops |
| W2-9 | `.gdignore` in `app/assets/terrain/decals_dds/`, `decals/` + report | 613 MiB unreferenced DDS excluded from Godot/export (NO tracked-file deletion without owner approval) |
| W2-10 | `app/assets/models/anim/naval/**`, `anim/naval/index.json` + report | Wire staged naval families; report exact `data.gd` keys needed (data.gd owned by W2-2) |
| W2-12 | `app/scripts/config.gd`, `app/scripts/menu.gd` | 5 donor AI difficulty tiers + per-slot tier selection |

Reports: `docs/coord_swarm_2026-11-24/reports/W2##_*.md`.
Backups: `inbox/backup/<name>.bak-W2##`.

Not assigned this wave (documented follow-ups): 259 MiB duplicate hardlinks,
Scotland art bake (needs Blender + asset lanes), adviser auto-control, randomized
AI strategies (needs game.rng ownership), full-map visual A/B gates.

## ## Session ids (coordinator supervision)

| ID | Session |
|---|---|
| W2-1 | ses_df34126a0ffeTBCT7apl0RM7X2 |
| W2-2 | ses_df341269fffeGbwHaEIRoxllTG |
| W2-3 | ses_df341269bffeFqqJL8Lv7X1jZI |
| W2-4 | ses_df3412683ffeS1nXgBVDoBlD0f |
| W2-5 | ses_df3412682ffes5kXfdX9v6BNy1 |
| W2-6 | ses_df341267fffe65P2W6Ojczdoq3 |
| W2-7 | ses_df340d9aaffed43hBh9xBh6JqL |
| W2-8 | ses_df340d9a7ffe4QhVjT7wENcmk0 |
| W2-9 | ses_df340d9a3ffeAd2fMT8nqB7VkE |
| W2-10 | ses_df340d994ffe4JO5S0t32MREGF |
| W2-12 | ses_df340d8a6ffe3M4kXD0TXfILM7 |

Final gate (after all workers release files)
selftest 29/29 + uitest 17/17 + clean CLEAN + subset spot-checks; see `FINAL_GATE.md`.
