# Wave 5 — close the honest residuals (owner directive 2026-11-24)

Owner: "keep covering remaining Honest residuals documented, not claimed: AI
force/wave acceptance still unmet, per-slot AI tiers can't reach the sim, <30 s
subsets not achieved, world.gd perf blocked by an environmental t_forest_bake
hang, two test-owner expectation updates, and the visual A/B for the new aura and
zoom feel."

Every residual is treated as OPEN until the assigned worker verifies current
source and produces evidence. Gates unchanged (backup, disjoint files, runner
only, targeted test, one report, coordinator final gate).

## Ownership map (disjoint)

| ID | Owned files | Residual |
|---|---|---|
| W5-1 | `app/scripts/ai.gd` | Force>=260 / wave>=1 still unmet; add per-slot tier CONSUMER (read Data.PLAYER_AI_DIFFICULTY) |
| W5-2 | `app/scripts/main.gd`, `app/scripts/selftest.gd` | Per-slot tier PLUMBING from cfg → AI; <30 s subsets via pre-baked map/dump restore |
| W5-3 | `app/scripts/world.gd`, new `app/tests/t_chunk_schedule_light.gd` | Replace hanging `t_forest_bake` verification with a light chunk-scheduling probe; re-attempt early-out only if measurable |
| W5-4 | `app/tests/t_hud_fidelity.gd`, `app/tests/uitest.gd` | Update `[N]`→`(N)` worker text and minimap-position expectations to match shipped HUD |
| W5-5 | new `app/shots/w5_*.png` + `reports/W55_visual_ab.md` (read-only code) | Visual A/B captures for aura + zoomed-out startup; honest verdict, owner final review |

## Cross-handoffs
- W5-1 ↔ W5-2: agree the per-slot difficulty API (Data key vs method call).
  W5-1 consumes; W5-2 plumbs. Neither edits the other's files.
- W5-3: `t_forest_bake` hangs on untouched baseline (jobs 1261/1268/1270 acked);
  do NOT use it as verification.

## Owner architecture directive (added 2026-11-24)
"Once map is created, don't render it in chunks — keep the whole built map in
memory; it's relatively small. Per-chunk reasoning is for open worlds, this game
is simple." Verified numbers: 320² tiles / CHUNK_T=32 → 100 chunks; runtime
presets low/med/high = 8/12/16 px per tile → whole-map single RGBA Image =
25/56/100 MiB (all resident-able); chunk rendering currently bakes 2/frame with
per-frame scan/sort and a forest LRU (~62 MB). The 20480² / 1.6 GB figure is the
diagnostic 64px PNG only, NOT a runtime preset. W5-3 (world.gd) now evaluates a
one-shot whole-map bake + single-Sprite2D path as PRIORITY; W5-6 is read-only
feasibility recon with measured memory/bake-time estimates and a main.gd handoff.

## Session ids
| ID | Session |
|---|---|
| W5-6 | ses_df2f4d696ffeBNPjkNElQdwSaK |
| W5-7 | ses_df2f1f913ffex5PLJCpXf8LptY |

## Owner directive added — edge-scroll acceleration
"more you move on the edges of the screen faster cam moves, maybe logarithmic
acceleration if mouse sits on one edge for prolonged time." W5-7 owns camera.gd
(free after W4-1 closed). Current state verified: binary edge bools + fixed
`mouse_speed` in `camera.gd:116-172`. Implement depth ramp + logarithmic dwell,
config keys with defaults, light verification only (t_nav_smoke), feel = owner review.
| ID | Session |
|---|---|
| W5-1 | ses_df2f95ff5ffegoAyS6yz4y0Fk2 |
| W5-2 | ses_df2f95ff2ffeM5Lo3DJ0gVFYB1 |
| W5-3 | ses_df2f920c7ffe0IK3uoALKttDjk |
| W5-4 | ses_df2f920c5ffeUvPQZrnVVC0Ex7 |
| W5-5 | ses_df2f920c2ffeiMAkwxilvs7FEZ |

Reports: `reports/W5##_*.md`. Final gate after all reports land.
