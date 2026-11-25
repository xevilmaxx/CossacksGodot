---
title: SWARM BOARD — terrain / selection / ghost visual swarm (2026-11-25)
owner: COORD
created: 2026-11-25
status: LIVE — 38 subagents dispatched
---

# 🐝 Swarm board — terrain visual quality

Charter: `docs/terrain_swarm_2026-11-25/CHARTER.md`
Reports: `docs/terrain_swarm_2026-11-25/reports/`

Owner rule: workers own exactly one output file (B owners also one exclusive source file).
COORD integrates and runs the only Godot jobs.

## Batch A — terrain diagnosis (read-only)

| ID | Scope | Session | State |
|---|---|---|---|
| A01 | shader tiling / diagonal streaks | ses_ded237739ffelgDNoFcXmDOozC | dispatched |
| A02 | alpha mask pattern artifacts | ses_ded237739ffdNsPVGQ4jyOQlah | dispatched |
| A03 | atlas cell content audit | ses_ded237736ffe66pumfqCLc2HQQ | dispatched |
| A04 | tile diversity in game.gd | ses_ded237717ffe95dkMTgiHh5yw0 | dispatched |
| A05 | relief visibility | ses_ded237712ffdWvRFfiNY2YZweI | dispatched |
| A06 | filtering / aliasing | ses_ded2376d9ffes8248gBKz314RZ | dispatched |
| A07 | colour / lighting metrics | ses_ded2376d9ffdeuZdOllrDktaTC | dispatched |
| A08 | local donor terrain truth | ses_ded2376d8ffeNCjgxXrw5Ilcox | dispatched |
| A09 | capture A/B tooling plan | ses_ded2376d8ffdkcnG4Xw6xuWXnR | dispatched |
| A10 | regression constraints | ses_ded2376d8ffcvz9TMOasMUjfCg | dispatched |
| A11 | reference image metrics | ses_ded2376d7ffeZOxr6VeTcZ7sx7 | dispatched |
| A12 | existing config knobs | ses_ded2376d7ffdKybyuvIBvq6gXR | dispatched |

## Batch F — online donor research (read-only)

| ID | Scope | Session | State |
|---|---|---|---|
| F01 | almanac: terrain / map gen | ses_ded230f68ffdwTO0fZFieVCDoo | dispatched |
| F02 | almanac: building stages / ghost | ses_ded230f65ffdelOnEEelaPJ8vi | dispatched |
| F03 | official patch notes: selection UI | ses_ded230f61ffeGebw2CU18JMIRM | dispatched |
| F04 | reviews / mods: visual quality | ses_ded230f45ffeRH9sNU568w8G3e | dispatched |
| F05 | online vs local reconciliation | ses_ded230f41ffd39r4W6Y5ePF1ia | dispatched |

## Batch D — selection quad (read-only D01-D06; B05 implements)

| ID | Scope | Session | State |
|---|---|---|---|
| D01 | current selection quad audit | ses_ded230efcffezScncR4yi7ju3j | dispatched |
| D02 | donor selection truth | ses_ded230ef4ffe40s8v5pUV07wlm | dispatched |
| D03 | decisive selection probe design | ses_ded230eefffeuWPw94iztuAXiz | dispatched |
| D04 | quad projection / geometry spec | ses_ded2296c8ffev6eDq3W3lXRRu8 | dispatched |
| D05 | wider selection UX defects | ses_ded2296c5fferJ61mXlocN8Ksf | dispatched |
| D06 | prior selection captures review | ses_ded22233affeJ3118xFfMAI79o | dispatched |

## Batch E — building ghost (read-only E01-E05; B06 implements)

| ID | Scope | Session | State |
|---|---|---|---|
| E01 | current ghost flow audit | ses_ded230ee9fferIqkHliqDRbxuN | dispatched |
| E02 | final-stage asset inventory | ses_ded230eabffe7Yo6aQfij96nKV | dispatched |
| E03 | ghost fix proposal/diff | ses_ded230ea9ffeBNepm5QZ1pzo7m | dispatched |
| E04 | ghost QA atom design | ses_ded230ea8ffeOSOmdGAro0xArn | dispatched |
| E05 | donor stage mesh naming | ses_ded222304ffe806jF8vkLDclbn | dispatched |

## Batch B — disjoint implementation owners (6 files, no overlap)

| ID | Exclusive file | Session | State |
|---|---|---|---|
| B01 | `variant3d/shaders/terrain_tileindex.gdshader` | ses_ded229759ffelRBI3RY5eFdGiV | dispatched |
| B02 | `variant3d/scripts/tile_atlas_loader.gd` + atlas `.import` | ses_ded229759ffdicFrqcKHP5Y8Os | dispatched |
| B03 | `variant3d/scripts/game.gd` | ses_ded229743ffeBCaHnUqsqjQ7ac | dispatched |
| B04 | `variant3d/scripts/world3d_terrain.gd` | ses_ded229726ffdXTlhqimEoovMth | dispatched |
| B05 | `variant3d/scripts/input_controller.gd` | ses_ded2296edffd3Uv4Tqd5PlynJj | dispatched |
| B06 | `variant3d/scripts/world3d_entities.gd` | ses_ded2296ecffed36vvKKPj76aD1 | dispatched |

## Batch C — verification tooling / QA (read-only except C01's one new tool)

| ID | Scope | Session | State |
|---|---|---|---|
| C01 | `variant3d/tools/terrain_ab_metric.py` | ses_ded2296ebffegeG6whB4ph4J7h | dispatched |
| C02 | integration gate plan | ses_ded2296eaffez0hO5LdplQWuot | dispatched |
| C03 | ownership/backup audit | ses_ded2296eaffdR0CALIDWqFurDK | dispatched |
| C04 | final visual sign-off protocol | ses_ded2296e5ffeEISI12mjRWLjXj | dispatched |

## COORD integration checklist

- [ ] All 38 reports landed (or explicitly timed out).
- [ ] C03 confirms disjoint edits + backups exist.
- [ ] Static parse/load check on all six edited files.
- [ ] Fresh 64² P0 capture + real-map capture, inspect with C01 metric and C04 protocol.
- [ ] If artifacts remain: second swarm wave targeted at the surviving defect (iterate until good).
- [ ] Gates: variant selftest 29/29, uitest 17/17, t_render_mode, assert_clean CLEAN; 2D untouched.
