---
agent: COMP-01
scope: test / gate completeness of variant3d/ (READ-ONLY)
date: 2026-11-24
status: GAPS REMAIN
---

# COMP-01 — Test / gate completeness (`variant3d/`)

Read-only audit per `docs/coord_swarm_2026-11-24/COMPLETENESS_CHARTER.md:7-14`.
No Godot launched, no git, no source/config/test edits. All timestamps are
filesystem local times; job timestamps are the `created` fields in
`variant3d/.godot_queue/status.json`. Snapshot taken during concurrent swarm
writes; claims below cite what was actually on disk at read time.

## 0. Registry totals

`variant3d/tests/manifest.json` registers **31 tests**:
- **24 inherited** (2D prefix, entries `:7-194`); 23 are `status:"ready"`,
  `t_weather` is `status:"pending"` (`:98-105`, no result artifact anywhere).
- **7 atomic 3D** (`:195-250`): `t_terrain3d`, `t_camera3d`, `t_pick3d`,
  `t_entities3d`, `t_fx3d`, `t_fog3d`, `t_render_mode`.
- Hygiene defect: manifest `result_dir` is `"app/tests/results"` (`:4`) while
  all 3D artifacts actually live in `variant3d/tests/results/`.
- `variant3d/tests/results/summary.json` is stale: `generated:1795257666`
  (2026-11-21 11:41), `count:19 / passed:19`, covers only the first 19 inherited
  tests and **no atomic test** (`summary.json:1-6`).

## 1. Coverage table — canonical gates

| Gate | 3D current value | 2D comparator | Freshness vs V7-92 | Evidence |
|---|---|---|---|---|
| selftest | `passed:true`, **29/29** steps all `passed:true` | `app/selftest.json` 29/29; **0** differing step/detail/pass strings (scripted Compare-Object) | written **16:08:02**, after terrain module edit 15:54:34 and after jobs 251/252 (15:56:41 / 15:58:10) | `variant3d/selftest.json:1-188`; jobs **254** `coord-final3-selftest` created 16:06:53, exit 0 (`status.json:5011-5028`), stdout `results/00000254_coord-final3-selftest/stdout.txt:9` |
| uitest | `passed:true`, **17/17** steps | `app/uitest.json` 17/17; **0** differing step/detail/pass strings | written **16:09:56**, after V7-92 | `variant3d/uitest.json:1-91`; job **255** `coord-final3-uitest` created 16:08:05, exit 0 (`status.json:5031-5048`), stdout `:3` |
| `t_render_mode` | **PASS 10/10**, `seam_missing:false`, status PASS | no 2D equivalent (3D seam test) | written **16:10:05**, after V7-92 | `variant3d/tests/results/t_render_mode.json:2-69`; job **256** created 16:09:59, exit 0 (`status.json:5051-5067`), stdout `:3-13` |
| 2D shipping gate | n/a | selftest 29/29 (job **1342** ok), uitest 17/17 (job **1341** ok), clean **CLEAN** documented | 2D jobs predate final 3D gate; app files untouched during wave | `app/.godot_queue/status.json:4940-4997` (1340 failed transiently under contention, 1341/1342 ok); `docs/coord_swarm_2026-11-24/PROGRESS.md:907-915`, `:1316-1320`, `docs/variant3d/STATUS_WAVE7_PHASE2.md:21` |

Caveats: the CLEAN verdict is a **documented** result (`PROGRESS.md:912`,
`:1320` — 0 processes, lock free, 9 acks); no fresh `assert_clean` JSON artifact
exists on disk, and under this read-only charter it was not re-run. No formal
**variant** CLEAN is claimed: the variant spool retains ~60 unacked probe-iteration
failures and has no `assert_clean.py` (`STATUS_WAVE7_PHASE2.md:40-42`). Spool
idle snapshot: `variant3d/.godot_queue/counter` = `now_serving` = 258.
`t_render_mode` is a **source/seam inspection** test (10 structural checks on
`main.gd`), not a runtime visual proof — `reports/V737_test_render_mode.md:16`.

## 2. The 7 atomic tests — honest per-artifact status

| id | Registered artifact? | Result in artifact | Freshness / later evidence | Evidence |
|---|---|---|---|---|
| `t_terrain3d` | `t_terrain3d.json` | `passed:true`, **6/6** (module load, build, surface 1, verts 102400, chunk/fallback, 3 height samples) | **STALE**: artifact 12:10:54; `world3d_terrain.gd` edited **15:54:34** by V7-92; test source (`:185,201,211,224,232,252`) has **no atlas/water/shader checks**. Post-integration evidence is only probe job **251** 20/20 (15:56:41) + selftest **252** + windowed shot **253**, not this test. | `variant3d/tests/results/t_terrain3d.json:2-43`; `status.json:4949-5008`; `results/00000251_v792-integration-probe-r2/stdout.txt:3-23` |
| `t_camera3d` | **NONE** (`t_camera3d.json` absent in both result dirs) | No artifact. Last actual run job **7** = FAIL `MODULE_MISSING` 0 checks (12:04); job **99** = **FAIL 8/14** (13:35): tilt `-0.000` vs `-32`, 3 round-trips returned `inf`, 0 viewport corners, empty view rect | **UNRESOLVED, pre-existing `_initialize()` tree-timing**. Harness still runs entirely in `_initialize()` (`t_camera3d.gd:97`, `root.add_child(cam)` `:127`, `bind` `:128`, `make_current` `:129`); camera module since edited 15:17:23 (V7-90) but test never re-run. `_v790_camera_probe.json` 8/8 (15:33) is a **different ad-hoc probe**, not the registered test. | `status.json:138-155`, `:1941-1957`; `results/00000007_v732-camera3d/stdout.txt:3-6`; `results/00000099_v766-t-camera3d/stdout.txt:10-19`; `PROGRESS.md:1060-1061`; `reports/V766_camera_jump.md:125,183-185`; `reports/TERRAIN2_05_leftovers.md:140` (TH-15) |
| `t_pick3d` | `t_pick3d.json` | `passed:false`, **0/6** — every check `MODULE_MISSING` / `NOT_RUN` | **STALE FAIL**: artifact 12:05:56; `picking3d.gd` landed 13:29:00. Later ad-hoc probes passed (job **127** 6/6 `V768 RESULT PASS`; job **141** ok) but no registered artifact was refreshed. | `variant3d/tests/results/t_pick3d.json:2-38`; `status.json:2494-2510`; `results/00000127_v768-pick-probe-final/stdout.txt:3-10` |
| `t_entities3d` | **NONE** under the registered id | Legacy artifact `v734_entities3d.json` = `passed:true`, **8/8** (`id:"v734_entities3d"`, not `t_entities3d`) | **STALE**: 12:20:41 vs `world3d_entities.gd` edited **14:22:22** (V7-65 tints). Job **49** stdout 8/8 PASS at 12:20; no post-tint registered run. | `variant3d/tests/results/v734_entities3d.json:2-55`; `results/00000049_v714-entities-test4/stdout.txt:3-10`; `status.json:945-961` |
| `t_fx3d` | **NONE** | No artifact. Green runs exist only as queue stdout: job **44** 13/13 (12:23), job **135** 13/13 (13:52, after `world3d_fx.gd` 13:31 edit). Earlier jobs 17/29 timed out, 33/37/40/43 failed. | **UNREGISTERED ARTIFACT**: current module is green in stdout, but no `t_fx3d.json` for the manifest id. | `results/00000044_v735-fx3d-verified/stdout.txt:3-17`; `results/00000135_v773-fx-regress/stdout.txt:3-17`; `status.json:851-866`, `:2654-2670` |
| `t_fog3d` | `t_fog3d.json` | `passed:true`, **9/9** | Fresh relative to module: artifact 12:31:28 vs `world3d_fog.gd` 12:27:52; job **65** ok. Coverage is API/array-size level, not donor fog↔explored fidelity. | `variant3d/tests/results/t_fog3d.json:4-55`; `status.json:1255-1272` |
| `t_render_mode` | `t_render_mode.json` | `passed:true`, **10/10** | Fresh: 16:10:05, job 256 after V7-92; `main.gd` last edited 13:49:51. | `variant3d/tests/results/t_render_mode.json:2-69`; `status.json:5051-5067` |

**Tints / donor player colours:** no manifest id and no result artifact at all.
Evidence is ad-hoc only: auto-skin probe job **181** exit 0 with 24 PASS checks
(`results/00000181_v778-auto-skin-probe3/stdout.txt:3-26`); documented 21/21 tint
probe in `STATUS_WAVE7_PHASE2.md:26` (V7-61 + V7-65).

## 3. Registered-but-missing / stale / failing artifacts (whole manifest)

- Missing artifacts: `t_weather` (registered `pending`, no result in either
  variant3d or app; script `t_weather.gd` exists), `t_camera3d`, `t_entities3d`,
  `t_fx3d` (manifest `:98-105`, `:203-234`).
- Failing artifact: `t_smoke_fx.json` `passed:false`, **5/6** — `artillery_explosion_fx`
  fails (`shots +0`); artifact 10:24:55. Same failure is present in the 2D
  `app/tests/results/t_smoke_fx.json:26,35`; `PROGRESS.md:1444-1447` documents it
  as pre-existing, not a 3D regression. `summary.json`'s 19/19 superseded by this
  later per-test artifact.
- Stale relative to recent 3D code: `t_terrain3d` (12:10 vs 15:54 module),
  `t_pick3d` (12:05 failed vs 13:29 module), `v734_entities3d` (12:20 vs 14:22
  module). `t_fog3d`, `t_render_mode`, `t_hud_fidelity` (12:24:52) and the final
  selftest/uitest are fresh.
- Inherited mass: most 2D-prefix artifacts are unchanged copies dated 2026-11-21
  … 2026-11-24 (e.g. `t_water.json` 11-21 11:40:37, `t_forest_bake*.json`
  11-23 17:57–17:58). They validate the shared mechanics, **not** any 3D
  rendering path; no 3D-specific re-run exists for them.
- `status.json` holds many unacked `failed` / `timed-out` probe jobs (e.g. 7,
  15, 18, 29, 33, 37, 40, 43, 46-48, 53, 56, 62, 81, 84, 99, 103, 107…); each
  is superseded by a documented passing job but no variant CLEAN verdict exists
  (`STATUS_WAVE7_PHASE2.md:40-42`).

## 4. Verdict — is the test suite COMPLETE for the shipped 3D features?

**NO — gaps remain.** The *functional gate* is complete and fresh: selftest
29/29 and uitest 17/17 were re-run after V7-92 integration with byte-identical
step names/details to the 2D gate, and `t_render_mode` is PASS 10/10 at 16:10:05.
But the *per-feature evidence base* is not complete:

- **Terrain atlas / water** — shipped by V7-92, but the registered `t_terrain3d`
  artifact predates the integration and tests none of the atlas/shader/water
  wiring. Only probe 251 (20/20) + selftest 254 + windowed shot 253 cover it.
- **Camera** — registered test has **no** passing artifact; last run FAILED 8/14
  on the documented `_initialize()` tree-timing harness bug, still present in
  current source. Only ad-hoc probe `_v790_camera_probe.json` 8/8 exists.
- **Picking** — registered artifact is a stale `MODULE_MISSING` FAIL; later probe
  passes are not registered.
- **Entities / FX** — registered ids have no result artifacts; only stale or
  stdout-only evidence.
- **Tints** — no registered test at all; probe-only evidence.
- **Inherited registry** — one pending test with no artifact (`t_weather`) and
  one failing artifact (`t_smoke_fx` 5/6, pre-existing in 2D).

So: gates green, suite **NOT complete as evidence**; no donor visual-parity claim
is made anywhere (`PROGRESS.md:298`, `STATUS_WAVE7_PHASE2.md:31-39,54-55`).

## 5. Top 5 gaps (prioritised)

1. **`t_camera3d` never green.** No artifact; job 99 FAIL 8/14; `_initialize()`
   tree-timing harness unchanged (`t_camera3d.gd:97-129`). Needs a deferred-run
   harness fix and a fresh registered run after the V7-90 camera edits.
2. **`t_pick3d` artifact is a stale FAIL** (0/6 `MODULE_MISSING`, 12:05) that
   predates `picking3d.gd` (13:29); later passing probes never refreshed the
   registered result.
3. **V7-92 terrain atlas + water untested by `t_terrain3d`.** Artifact 6/6 is
   from 12:10, module changed 15:54; test has no atlas/shader/water checks.
   Only probe 251/selftest 254/shot 253 cover the shipped feature.
4. **`t_entities3d` and `t_fx3d` have no canonical artifacts.** Latest green
   evidence is queue stdout only (job 49 8/8 stale; job 135 13/13); add fresh
   `t_entities3d.json` and `t_fx3d.json`.
5. **Registry hygiene / residual failures.** `t_weather` pending with no artifact;
   `t_smoke_fx` 5/6 FAIL unresolved (pre-existing in 2D); `summary.json` 19/19
   stale; manifest `result_dir` points to `app/tests/results`; no registered tint
   test; no formal variant CLEAN verdict.
