---
id: SP8-STATUS-01
task: "Audit the season-overlay atom's stale report and define its required re-run"
agent: "SP8-STATUS-01 (read-only verification worker)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GIT_CHANGE__NO_DONOR_ACCESS
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/SP8_STATUS_01.md"
scope: "One report only. Read-only inspection of reports, atom source, on-disk artifacts, SWARM_BOARD and runner spools; no Godot launch, no runner ticket, no atom/test/source/asset/JSON edit, no git mutation."
verification_passes: 1
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; a re-check never certifies donor parity (CAPTURE_RECHECK.md:10,35,237)."
no_repo_change_except_this_report: true
---

# SP8-STATUS-01 — stale SP-08 report audit and re-run specification

## 1. Sources (all read-only this pass)

| # | Source | Use / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SP_08_season_test.md` | Atom's authoring claims: `:6-16` frontmatter, `:89-99` design, `:105-146` assertions/verdict rule, `:150-170` dependency table, `:174-193` predicted state, `:258-282` no-run declaration and proposed command — observed |
| S2 | `docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md` | `:161-168` "already landed" inventory + "no `t_season_overlay.json` on disk", `:178` rank 7, `:191` C2 stale-claim correction, `:211` Q7 "Was SP-6 actually run?" — observed |
| S3 | `docs/coord_swarm_2026-11-25/reports/SP_06_renderer_hook.md` | `:64-66` SP-8 read-only note, `:117-139` season table and path correction, `:145-196` hook/stats, `:230-248` smoke jobs, `:290-295` O1 stale path handoff — observed |
| S4 | `docs/coord_swarm_2026-11-25/reports/QA_WINTER_01.md` | `:44-52` artifact hashes, `:92-105` path-mismatch section, `:120-135` C9 `PARTIAL`, `:140-141` Q3/Q7 — observed (now stale on C9) |
| S5 | `variant3d/tests/t_season_overlay.gd` (1,057 lines, read only) | `:53-74` constants, `:165-178` `_verdict()`, `:354-411` dependency gate, `:613-631` manifest/path assertions, `:838-889` cross-variant checks, `:892-959` result JSON, `:970-1057` setup — observed |
| S6 | `docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md` | `:41-83` artifacts/commands/prerequisites, `:87-91` PASS/FAIL/N/A and separate verdicts, `:230-267` image rules, `:244-250` recording/COORD-only advance, `:254-267` failure attribution — observed |
| S7 | `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` | `:173` SP-8 row, `:240` CAPTURE-RECHECK-01, `:243-248` QA-WINTER-01 / SEASON-TEST-PATH-01 / DSEASON-01 / DESERT-REMAP-02 / PROP-W-PLAN-01 / SP8-STATUS-01, `:253-254` QA-ATOM-RESULTS-01 / LFS-PLAN-01; `:5-6` COORD owns only the State column — observed |
| S8 | On-disk existence/size probes of atom result JSON, atlas/manifest/JSON data, fixture and harness | §2 table — observed |
| S9 | `git status --short`, `git log -5 --oneline`, `git log -p -1 -- variant3d/tests/t_season_overlay.gd` | Commit `1d67e32b` (2026-11-25 11:14:22 +0100) changed `:59-60` from `tile_index_winter_atlas.*` to `tile_index_atlas_winter.*`; file currently clean — observed |
| S10 | `variant3d/.godot_queue/results/00000466.json`, runner spool listing, `variant3d/tools/godot_runner.py:349-419,572-575` | Ticket 466 `seasonpath01-smoke` argv/status `skipped` (serving=467); runner passes argv verbatim to Godot — observed |
| S11 | Python read-only `json.load` of Winter manifest | `atlas.grid == [16,8]`, `named_cells == 124`, `layout` length 124 — observed |

**Labels:** `observed` = literal file/bytes/command output read this pass; `derived` = deterministic consequence of observed code/state; `inferred` = reading with a stated caveat; `UNVERIFIED` = not provable from available material (donor parity, LFS remote, a run that has not happened).

---

## 2. On-disk state table (this pass)

| Item | Expected path / condition | Observed on disk | Label |
|---|---|---|---|
| Atom result JSON | `variant3d/tests/results/t_season_overlay.json` | **MISSING**. Directory listing shows 63 other result JSONs; no season file | observed |
| Atom source | `variant3d/tests/t_season_overlay.gd` | Present, 1,057 lines, git-clean; two TODO constants now **fixed** — `:59` `WINTER_MANIFEST_PATH := ".../tile_index_atlas_winter.manifest.json"`, `:60` `WINTER_ATLAS_PATH := ".../tile_index_atlas_winter.png"` (no `tile_index_winter_atlas*` anywhere in the two constants) | observed |
| Path-fix provenance | SEASON-TEST-PATH-01 | Commit `1d67e32b` "step" (11:14:22 +0100) made exactly the two-line swap; board row still `RUNNING` (S7 `:244`) and no `reports/SEASON_TEST_PATH_01.md` found; smoke ticket 466 was `skipped` | observed |
| SP-4 Winter manifest | `assets/terrain/atlas/tile_index_atlas_winter.manifest.json` | **EXISTS**, 79,837 B; `grid [16,8]`, `named_cells 124`, 124 layout rows | observed |
| SP-4 Winter atlas PNG | `assets/terrain/atlas/tile_index_atlas_winter.png` | **EXISTS**, 124,463,306 B (hash in S4 `:48`) | observed |
| SP-2 dictionary | `assets/terrain/atlas/winter_aliases.json` | **EXISTS**, 81,335 B (124 entries; QA-WINTER C2/C3) | observed |
| SP-3 remap | `assets/terrain/atlas/desert_remap.json` | **EXISTS**, 9,395 B (11 direct + 1 gated; atom `:567` expects exactly that) | observed |
| Summer baseline | `tile_index_atlas.manifest.json` / `.png`, `structs/presets_summer.json` | **EXIST** (60,677 B / 179,912,941 B / 1,443 B) | observed |
| Fixture + harness | `tests/fixtures/small_map_64.json`, `_smallmap_harness.gd` | **EXIST** (733 B / 7,785 B); fixture `gameplay` = 64×64, seed 20261113 | observed |
| SP-1 enum | `scripts/data.gd:199,227` | `static var BIOME := "summer"`, `const SEASON_ENUM := {"summer":0,"winter":2,"desert":3}` — present | observed |
| SP-5 override | `scripts/tile_atlas_loader.gd:76-77,84-86,115-117` | Both `single_atlas_path` and `manifest_path` config keys present | observed |
| SP-6 hook | `scripts/world3d_terrain.gd` | Present: `:272-280` paths + `SEASON_ATLAS`, `:400/:413/:430` selector/loader, `:569-603` loader override, `:1244` `season_is_desert`, `:1340-1346` remap before `UV2.x`, `stats` provenance per SP-06 §4.6 | observed |
| Runner spool | `variant3d/.godot_queue/results/00000466.json` | `id=seasonpath01-smoke`, argv `--headless --path variant3d --check-only --script res://tests/t_season_overlay.gd`, `status=skipped`, `error="ticket 466 was skipped (serving=467)"`, no stdout/stderr written — **the path fix has no recorded validation run** | observed |

**Conclusion:** every dependency gate in the atom is now satisfied on disk, and the stale path constants are fixed. No atom execution has occurred, so no verdict exists.

---

## 3. Stale-claim table

| Prior claim | Current verified state | Verdict / source |
|---|---|---|
| SP-08 frontmatter `status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_PASS_CLAIM` (S1 `:6`) | Still true for SP-08 itself; no result JSON, no captured PNG from that ticket, no spool row with `t_season_overlay.gd` as a *run* (ticket 466 was check-only and skipped) | **CURRENT** — observed |
| SP-08 §5: SP-4 Winter manifest/PNG "absent" → Winter `PENDING_DEP` (S1 `:157`) | Both files exist with the corrected `tile_index_atlas_winter.*` names (§2) | **STALE** — corrected also by S2 C2 (`:191`) and S3 §4.2 |
| SP-08 §5: SP-6 hook "absent" → Winter/Desert `PENDING_DEP` (S1 `:159`) | Hook present in `world3d_terrain.gd` (`BIOME`, `desert_remap`, both probes pass) | **STALE** — corrected by S2 `:161-168` |
| SP-08 §5: SP-1/2/3/5 "present", paths `atlas/winter_aliases.json` and `atlas/desert_remap.json` (S1 `:154-158`) | Unchanged; SP-1 `SEASON_ENUM`, SP-5 `manifest_path` confirmed again | **CURRENT** — observed |
| SP-08 §6 predicted windowed verdict `PENDING_DEP`, only Summer PNG (S1 `:191-193`) | With all deps present and windowed capture, the code path yields all three `BUILT` + three PNGs; expected verdict `PASS` (§5, derived) | **STALE (prediction only)** — derived from S5 `:165-178,390,673-676,899-942` |
| SP-08 §9 proposed command uses constants `tile_index_winter_atlas.*` indirectly via `t_season_overlay.gd:59-60` (S1 `:266-276`) | The two constants have been corrected in commit `1d67e32b`; the launch form itself remains the correct serialized-runner form | **PARTLY STALE** — observed |
| SP-06 O1 / QA-WINTER-01 C9: "test constants still use obsolete name, alignment `PARTIAL`" (S3 `:290-295`, S4 `:66,98-105,132`) | Both constants now aligned; those reports were accurate at their time but are stale now. Renderer was aligned already | **STALE** — observed |
| DSEASON-01 C7 / Q7: "no `t_season_overlay.json`, SP-6 never run / no visual check" (S2 `:178,211`) | Confirmed again this pass — result JSON still missing | **CURRENT** — observed |
| QA-WINTER-01 C10: old LFS pointer precondition refuted, remote LFS availability UNVERIFIED (S4 `:107-118`) | No new evidence this pass; unchanged | **CURRENT / UNVERIFIED** — observed |

### 3.1 Resolution of every `PENDING_DEP` condition

| Variant | Gate conditions (atom `_make_variant`, S5 `:366-411`) | State now |
|---|---|---|
| Summer (mandatory baseline) | Summer V785 manifest + `presets_summer.json` | Both present → `READY` (`STATUS_FAIL` only if missing) |
| Winter | SP-2 dictionary; SP-4 manifest; SP-4 PNG; SP-5 `manifest_path` probe; SP-6 `BIOME` probe | **All five satisfied** → `READY`. The two file gates were the blocking pair and are now unblocked by the corrected constants + landed artifacts |
| Desert | SP-3 remap JSON; SP-6 `desert_remap` source probe | Both present → `READY` |
| Headless capture | `DisplayServer.get_name()=="headless"` ⇒ `SKIP_CAPTURE`, no PNG (S5 `:673-676,934-936`) | Not a missing dependency; a deliberate run-mode outcome |

Therefore no `PENDING_DEP` check should remain after a correctly launched windowed re-run; the only inherently pending row is `script_error_scan_external` (`PENDING_EXTERNAL_SCAN`, S5 `:887-889`).

---

## 4. Required re-run (specification only — NOT executed)

### 4.1 Exact command (Windows `python`, repo root, serialized variant runner)

```
python variant3d\tools\godot_runner.py run --id sp8-status-season-overlay-01 --timeout 300 --max-wait 3600 -- --path variant3d --script res://tests/t_season_overlay.gd -- --summer-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_summer.png --winter-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_winter.png --desert-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_desert.png
```

- **Unique id:** `sp8-status-season-overlay-01`. S10 spool listing contains no such id; avoids `seasonpath01-smoke` (466, skipped) and all later ids through 487. The runner derives the spool directory `variant3d\.godot_queue\results\<ticket>_<id>\` (S10, runner `:357`), so the id also names the stderr artifact for the re-check.
- **Windowed, not headless (required):** the atom's `capture_image`, `capture_saved`, `non_black_fraction` and `full_width_dark_rows` checks and the whole three-variant `PASS` verdict exist only in the windowed branch (S5 `:673-676,721-771,934-936`); headless yields `SKIP_CAPTURE`, `passed=false` and no PNGs. CAPTURE_RECHECK §1.1 prerequisite 1 likewise rejects headless as PASS (`CAPTURE_RECHECK.md:57`). A headless run has diagnostic value only and must be recorded as `SKIP_CAPTURE`, never harvested as a green result.
- **`--timeout 300`:** three sequential builds load the ~180 MB Summer PNG and the 124 MB Winter PNG and each take a 10-frame windowed capture (S5 `:70,264-272,814-818`). SP-08 proposed 180 s (S1 `:271`), but that estimate is unverified; 300 s follows the scale of the recent 64² capture jobs while retaining the hard-kill guarantee (runner `:403-412`). `--max-wait 3600` (runner default) is stated explicitly because the queue already showed a 812 s wait before ticket 466 was skipped.
- **User args after the second `--`:** runner `cmd_run` consumes only the first `--` and passes the remainder verbatim to Godot (S10, runner `:602-603`); the atom reads `--winter-png` / `--desert-png` from `OS.get_cmdline_user_args()` (S5 `:181-187,355-363`). No `--config` is needed: the atom defaults to the 64² fixture with seed 20261113 (S5 `:240-255`). The atom creates the output directory recursively (S5 `:750-752`), so no pre-flight directory edit is required.

Externally, read-only, after the job finishes (do **not** run any of these in this task):

```
python variant3d\tools\smallmap_capture.py stats C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_summer.png
python variant3d\tools\smallmap_capture.py stats C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_winter.png
python variant3d\tools\smallmap_capture.py stats C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/season_overlay_rerun/season_desert.png
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_sp8-status-season-overlay-01\stderr.txt
```

### 4.2 Expected verdict fields (derived from S5 `:892-959`; NOT an observed run)

| Field | Expected value / assertion |
|---|---|
| `id` | `"t_season_overlay"` |
| `verdict` | `"PASS"` if all three variants build, all three PNGs pass and no evaluated check is false; otherwise `FAIL` (any false), `INCOMPLETE` (built/capture mismatch) or `SKIP_CAPTURE` (headless). `PENDING_DEP` must **not** reappear |
| `passed` | `true` only when `verdict == "PASS"`; note `script_error_scan_external` stays pending, so this field is derived from the verdict, not from every check being true |
| `passes` / `fails` / `skipped_or_pending` | Derived expectation on the happy path: **47** check entries = **46** true / **0** false / **1** pending (`script_error_scan_external`); `fails == 0` is the hard gate |
| `variants[]` | Three rows (`summer`, `winter`, `desert`), each `status == "BUILT"`, `missing == []`, `capture_status == "PASS"`, `uv2_out_of_range == 0`; `manifest` = Summer V785 for summer/desert and `tile_index_atlas_winter.manifest.json` for winter; `png_path` equals the corresponding user arg; `atlas_mode` expected `"single"` |
| `checks[]` | Expect `summer_dependency_state`, `winter_dependency_state`, `desert_dependency_state` all `PASS`; all `*_build_ok`, `*_manifest_resolves`, `*_manifest_grid` (`[16,8]`), `*_atlas_selection`, `*_uv2_entry_count` (4,096), `*_uv2_x_in_range` (0 bad), `*_capture_image`, `*_capture_saved`, `*_non_black_fraction` (>0.9), `*_full_width_dark_rows` (0) `PASS`; `winter_dict_124_entries`, `winter_entries_index_and_names`, `winter_names_resolve` (0 missing PNGs) `PASS`; `desert_remap_parsed` (11 direct + 1 gated), `desert_remap_targets_resolve` `PASS`; cross-variant `tileblock_index_preserved`, `uv2_x_summer_winter_identical`, `uv2_x_desert_remap_consistent` (0 mismatches), `no_script_errors_internal` `PASS`; `script_error_scan_external` `PENDING_EXTERNAL_SCAN` with `passed: null` |
| `measured` | Must include fixture 64×64 / seed 20261113, `summer_names == 124`, `sp5_manifest_path` / `sp5_single_atlas_path`, per-variant `atlas_mode`, `uv2_x_min/max/out_of_range`, `*_png_metrics` (1280×720, byte size), `winter_entries`, `winter_kinds`, `desert_uv2_mismatches`, `dependency_note`, `display_server` (not `headless`), `harness_source` |
| `harness_source` | Expected `"shared:res://tests/fixtures/_smallmap_harness.gd"` if the helper instantiates; `"embedded_local_stub"` is the declared fallback (S5 `:300-329`) — record whichever occurs, do not treat the fallback as a pass claim |
| `headless` / `skip_reason` / `capture_status` | `false` / `""` / `"see variants[].capture_status"` in the windowed run |
| `script_error_note` / `parity_label` | Standby strings: external stderr scan required; `PORT APPROXIMATION — internal consistency only`, no donor GPU A/B |
| Runner exit code | `0` when no evaluated check is false (S5 `:957-959`); **the JSON verdict, not the exit code, is the gate**. A `PENDING_DEP` or `SKIP_CAPTURE` run can also exit 0 while `passed=false` |

---

## 5. Second-agent re-check criteria (per `CAPTURE_RECHECK.md`)

The re-checker must be a **second agent, never the builder who ran the job** (`CAPTURE_RECHECK.md:6,249`); this worker is not that re-checker and performs none of it.

1. **Artifacts to open:** the three PNGs (`season_summer.png`, `season_winter.png`, `season_desert.png`), `variant3d\tests\results\t_season_overlay.json`, and runner `stdout.txt` / `stderr.txt` from `variant3d\.godot_queue\results\<ticket>_sp8-status-season-overlay-01\`. No `frames.json`: this atom claims no motion (`:52`).
2. **Capture-integrity prerequisites (hard):** windowed launch, no `--headless`; each PNG exists, is 1280×720 and non-blank with `capture_image` / `capture_saved` true in the JSON; `scan-stderr` reports `script_error_lines: 0`; the fixed 64² harness / seed 20261113 / one camera / ~10-frame capture were reused (`:56-60`).
3. **Commands (read-only, Windows `python`):** the four `smallmap_capture.py stats` / `scan-stderr` commands in §4.1, outputs recorded verbatim. `stats` is qualitative only — never a substitute for opening the PNG (`:82`).
4. **Checklist:** mark exactly one of `PASS`/`FAIL`/`N/A` per criterion — setup (`summer_dictionary`, `harness_stub_shape`, `sp5_manifest_override_api`, `terrain_camera_scripts`); per-variant dependency/build/manifest/grid/atlas-selection/UV2 checks; Winter dictionary trio; Desert remap pair; cross-variant tileblock/Summer–Winter equality/Desert remap consistency/internal-error; three captures (image/saved/non-black/dark-rows); `script_error_scan_external` = `N/A`/external until the operator scan exists. Blank = `UNVERIFIED`, not PASS (`:89-91`).
5. **Two separate verdicts:** record "atom JSON verdict" and "second-agent image verdict" independently. A green JSON never overrides a visible defect; keep `observed` / `derived` / `inferred` / `UNVERIFIED` separated and describe regions in words for each of the three PNGs (frame fill/corners, horizon/ground, tiles/seams, tonal range, season colour signature) — `:91,230-238`.
6. **No donor parity:** every finding is `PORT APPROX — internal consistency only`; no donor A/B frame exists, so "winter looks snowy" or "desert looks sandy" is a description, never a parity certificate (`:10,35,237,267`).
7. **No instrument changes:** no threshold lowering, no assertion deletion, no rerun hoping for green. If `full_width_dark_rows == 0` fails because the predicate is inapplicable to this frame composition, record the value and the visual reading, then route an evidence-backed ticket using the P0_GATE-01 precedent — do not relax the atom (`:239,263-265`).
8. **Recording / authority:** write one `reports/RECHECK_<ROW>.md` with frontmatter, four artifact paths, two command outputs verbatim, filled checklist, region description, separate verdict fields and any exact failed assertion (`:246-248`). **COORD alone** advances any ladder row after reading it (`:249`); FINAL remains COORD-only and last (`:250`).

---

## 6. Remaining blockers and owners (from `SWARM_BOARD.md`)

| # | Blocker / caveat | Owner per board | Kind |
|---|---|---|---|
| B1 | SEASON-TEST-PATH-01 is still `RUNNING` (`:244`), its report `reports/SEASON_TEST_PATH_01.md` does **not** exist on disk, and smoke ticket 466 was `skipped` — the two-line path fix is present and committed but has neither a landed report nor a validation run | SEASON-TEST-PATH-01, session `ses_dedd5c6b9ffebY8CjZ2LHhmm8U`; board State column: COORD | Documentation/validation gap, **not** a code blocker. Close the row or record the skipped smoke before treating the fix as formally delivered |
| B2 | No runner owner is assigned for the atom itself: SP-08 was authoring-only, and both DSEASON-01 rank 7 / Q7 (S2 `:178,211`) and QA-WINTER-01 Q7 call for a runner owner | COORD (board owner, `:5-6`) — a runner ticket must be authorised by COORD; the executing agent may not self-certify | **Real gate** for the re-run in §4.1 |
| B3 | `script_error_scan_external` can never be `PASS` inside the atom; an operator must run `scan-stderr` on runner stderr | Runner operator / COORD (`CAPTURE_RECHECK.md:59`; S5 `:887-889`) | Permanent pending field, not a failure |
| B4 | Second-agent re-check role is unfilled for this atom and the protocol's `<ROW>` list covers only P0–S1; no `RECHECK_SEASON_OVERLAY.md` convention is defined | COORD owns protocol; re-check by a SECOND AGENT (`CAPTURE_RECHECK.md:6,246-249`) | Process/scope decision needed before a re-check can be recorded |
| B5 | Desert remap covers 11 of 38 donor-active pairs (S2 `:172`, C5 `:194`); the atom asserts only the 11 landed pairs | DESERT-REMAP-02, `RUNNING`, session `ses_dedc825e3ffeCybE4oju7Ds2Az` (`:246`) | Scope/parity caveat: a green atom does **not** close the visual gap; no parity claim allowed |
| B6 | No winter prop-`w` art in the port; atom is terrain-overlay-only | PROP-W-PLAN-01, `RUNNING`, session `ses_dedc825dfffe65At77RG2CJO98` (`:247`) | Scope caveat, outside this atom's assertions |
| B7 | Remote LFS availability of `5d0dd8f3…` UNVERIFIED; local PNG exists, so a local run is possible, but a fresh clone may not smudge | LFS-PLAN-01 `DONE` (`:254`); git/LFS choice explicitly COORD-owned per S3 `:285` | UNVERIFIED; not a local-run blocker |
| B8 | QA-ATOM-RESULTS-01 is auditing atom result JSONs and manifest consistency | `RUNNING`, session `ses_dedcdf2c3ffeeNnd0m5fmCmM6R` (`:253`) | Coordination: the new `t_season_overlay.json` will appear under that lane's scope |
| B9 | Queue contention — recent jobs were skipped (466 after an 812 s wait, serving=467); a windowed three-atlas job needs a unique id and explicit `--max-wait` | Runner/COORD (single-door policy, S10) | Operational; §4.1 id and `--max-wait` address it |
| B10 | Atom is intentionally unregistered in `manifest.json` / `test_all.py` (S1 `:252-254`) | Integration ticket — **no board row found** | Launch by hand via the serialized runner; open question who registers it |

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Will SEASON-TEST-PATH-01 land `reports/SEASON_TEST_PATH_01.md` and have COORD mark it DONE, given that its code fix is already committed? The skipped smoke 466 leaves the fix unvalidated by a recorded job.
2. Does COORD require a fresh headless `--check-only` smoke of the corrected atom before authorising the windowed re-run? This worker did not submit one.
3. Where should the season-overlay re-check be recorded — `RECHECK_SEASON_OVERLAY.md` by extension, or a new `<ROW>` name defined by COORD? `CAPTURE_RECHECK.md:247` enumerates P0–S1 only.
4. Will the Winter atlas actually bind at runtime, or will SP-6's labelled Summer fallback fire (`SP_06_renderer_hook.md:252-266`) because of an LFS/loader problem? The atom's `atlas_selection` reads `stats`, so a wrong bind is expected to surface as a FAIL — but only a run can show it.
5. Is `full_width_dark_rows == 0` applicable to this three-variant 64² windowed frame? Do not weaken it; if it fails, use the P0_GATE-01 evidence-backed replacement route (`CAPTURE_RECHECK.md:239,263-265`).
6. Should the atom later be extended from 11 to 38 Desert pairs? That is DESERT-REMAP-02's decision; changing the atom's expected counts in this re-run would be weakening/scope drift.
7. Is `--timeout 300` sufficient for three sequential atlas loads? No prior timing evidence for this atom exists; if it times out, raise it with a runner-owner ticket rather than reducing assertions.
8. Can the Winter and Summer atlases coexist in memory for the three builds (SP-08 Q5 `:244-249`, B2 of the plan)? The atom frees each terrain but does not force a texture-cache flush; unverified until execution.

---

## 8. Summary

1. **Stale report confirmed in part.** SP-08's `PENDING_DEP` prediction and its SP-4/SP-6 "absent" rows are stale: all six dependencies SP-1…SP-6 are now satisfied on disk. DSEASON-01's C7/Q7 finding — no result JSON and no recorded run — is **still accurate**.
2. **Path fix is present.** `t_season_overlay.gd:59-60` now use `tile_index_atlas_winter.*`, matching SP-4's artifact names and SP-06's renderer constants; commit `1d67e32b` made the swap. SP-06 O1 and QA-WINTER-01 C9 are therefore stale on this point, and SEASON-TEST-PATH-01's board row/report/smoke are behind the code.
3. **No verdict exists.** `variant3d/tests/results/t_season_overlay.json` is missing; the only runner record touching this atom is a skipped check-only smoke (466). Nothing may be called PASS until a windowed serialized run plus the second-agent capture re-check both exist.
4. **The required action is one authorised windowed re-run** with the exact command in §4.1, followed by `stats` on all three PNGs, a `scan-stderr` operator scan, and a second-agent `RECHECK` report as specified in §5. Headless is explicitly not a substitute.
5. **No file other than this report was edited.** No code, test, asset, config, fixture, result JSON or git state was changed; no Godot process was launched; no runner ticket was submitted; no donor file was accessed; no test assertion was weakened; no visual-parity claim is made.

*End of SP8-STATUS-01. Read-only audit and re-run specification only.*
