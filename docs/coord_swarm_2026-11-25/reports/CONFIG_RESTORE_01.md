---
id: CONFIG-RESTORE-01
title: "Restore the full 21-key features block in variant3d/config.json — 21/21 leaves present, relief stays on, map stays 320²; smoke ok, uitest watchdog-failed"
agent: CONFIG-RESTORE-01 (implementation builder, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE__PARTIAL_VALIDATION__UITEST_WATCHDOG_TIMEOUT
scope: "Exactly two owned artifacts: variant3d/config.json and this report, plus one backup copy. No source, test, gate, fixture, app/**, donor or other doc file edited."
owner_files:
  - variant3d/config.json
  - docs/coord_swarm_2026-11-25/reports/CONFIG_RESTORE_01.md
backup: inbox/backup/config.json.bak-CONFIGRESTORE (14,477 B, SHA-256 bd80c2d10d1fbfee05ec6042cb90df02269a539d561f373355db1f86348bf0f5, byte-identical pre-edit copy)
labels: [observed, derived, historical snapshot, UNVERIFIED, BLOCKED (validation)]
verdict: RESTORED__20_DEFAULTS_PLUS_INTENTIONAL_RELIEF_TRUE__JSON_VALID__SMOKE_OK__UITEST_NO_FRESH_VERDICT__MAP_320_UNCHANGED
---

# CONFIG-RESTORE-01 — restore the full 21-key `features` block

> [!IMPORTANT]
> Donor is truth, but this ticket is a **config-file restoration**, not a donor or
> runtime-behaviour claim. Every restored leaf is a verbatim copy of a value in
> `config.gd:46-84` (`FEATURES_DEFAULTS`, CONFIG-CORE-01). Values already labelled
> `PORT APPROXIMATION` / `UNVERIFIED` in the code keep that label here; JSON has no
> comment syntax, so the labels remain in `config.gd` and are restated below.
> No consumer wiring, no donor parity and no green gate is claimed. Every Godot
> launch went through `variant3d/tools/godot_runner.py`; no direct `godot`, no gate,
> no ladder, no test weakening, no queue mutation and no re-submit.

---

## 1. Evidence read (all read-only)

| Source | Fact used |
|---|---|
| `variant3d/scripts/config.gd:46-84` | `FEATURES_DEFAULTS`: 21 leaves in 8 groups; the exact literal values restored. Comment `:42-45`: every value is today's verified behaviour, no consumer reads these yet. |
| `variant3d/scripts/config.gd:88-89` | `DEFAULT["features"] = FEATURES_DEFAULTS`; a JSON `features` object merges key by key, so every key is optional. |
| `variant3d/config.json` (pre-edit, 837 lines) | Only `features.terrain.relief_stamps: true` (5 additive lines from RELIEF-ENABLE-01); `gameplay.map_width_tiles/map_height_tiles = 320`, `map_type: land`; 12 top-level keys. |
| `inbox/backup/config.json.bak-CFGJSON` | 14,409 B, **no** `features` key, map **240²** — the pre-insertion baseline, **not** the 21-key version as the ticket guessed. |
| `inbox/backup/config.json.bak-RELIEFENABLE` / `.bak-MAPSMALL01` / `.bak-CFG02` / `.bak-V750` / `.bak3` / `.bak_unify_mine` | All also have **no** `features` key (checked programmatically); no on-disk backup of the 21-key block exists. |
| `git show 1d67e32b:variant3d/config.json` | The only surviving 21-key block; used as the **exact text/indentation template** (8 groups, 21 leaves, one-space/two-space/three-space indentation). |
| `reports/RELIEF_ENABLE_01.md:54-72,94-104,186-189` | MAP-SMALL-01 reverted both files; the minimal one-leaf block was a deliberate deviation; its Q1 asked for exactly a separate ticket re-adding all 21 leaves. |
| `reports/QA_CONFIGJSON_01.md:29-59,73-85,89-98,102-126` | Earlier "21/21 MATCH" audit of a 240² file with `relief_stamps: false`; stale for today's file in two ways (§6). |
| `reports/MAP_SMALL_01_report.md:14-25,92-108,110-153` | 21-key block was added then removed by the mandatory full revert; 240² best result 28/29 with `build` red; `build`/site-layout failure is still being diagnosed. |
| `RUN_GUIDE.md:44-57,101` | Variant-runner command shape, unique `--id` rule, expected FIFO waits, and the standing 28/29 (`build`) selftest state. |

---

## 2. Backup and byte-level integrity

- Pre-edit backup: `inbox/backup/config.json.bak-CONFIGRESTORE`, written with `shutil.copyfile`
  **before any edit**, 14,477 B, SHA-256
  `bd80c2d10d1fbfee05ec6042cb90df02269a539d561f373355db1f86348bf0f5`
  (matches the post-RELIEF-ENABLE-01 hash quoted in `RELIEF_ENABLE_01.md:80`).
- Post-edit `config.json`: 15,163 B, SHA-256
  `0514f3ff126f2e80567132ce723a7338a5756ffd03322ee7fcda67b5bac4d648`,
  872 lines, CRLF preserved (**871 CRLF, 0 bare LF**).
- The replaced text was exactly the 5-line partial block (68 B) at `:16-20`; the
  replacement is 754 B. Net **+34 lines, 0 deletions outside that block**.
- Programmatic checks (`python` 3.14, `json.load`):
  - JSON parses: **OK**.
  - Feature groups: `selection, terrain, water, weather, camera, hud, render, gameplay` (8).
  - Leaves: **21**, extra `[]`, missing `[]`.
  - 20 leaves equal their `config.gd:46-84` default; the sole intentional deviation is
    `terrain.relief_stamps` (`false` in code, `true` in JSON — preserved from RELIEF-ENABLE-01).
  - Removing the new block from the current bytes reproduces the backup **byte-for-byte**
    (`byte-identical outside features block: True`).
  - Parsed-value deep comparison of every other top-level key vs the backup: **equal**
    (`EQUAL excluding features: True`).
  - Map: **320 × 320**, `map_type: land`, seed `20261113`; unchanged.
- Final check (after the runner jobs): `git diff -- variant3d/config.json` is empty.
  HEAD moved during this ticket (`2101e66e`, `52a81f97`, `cd90a181`), and the current
  HEAD copy of `config.json` already contains these same 21 leaves, `relief_stamps:
  true` and 320². This is **observed**, not claimed as this agent's commit — no
  `git` write was made by this ticket.

---

## 3. Key-by-key before → after (21 rows)

"Before" is the pre-edit backup; `absent` means the key was **not in the JSON** and
therefore resolved from `config.gd:46-84`. "After" is the explicit JSON leaf at
`config.json:16-54`. Effective runtime values are unchanged for all 21 keys — this
is a configurability restoration, not a behaviour change.

| # | Dotted key (`features.*`) | `config.gd` default | Before (JSON) | After (JSON) | Effective before → after |
|---|---|---|---|---|---|
| 1 | `selection.world_epsilon_m` | `0.005` | absent (inherits `0.005`) | `0.005` | `0.005` → `0.005` |
| 2 | `selection.attack_epsilon_m` | `0.25` | absent (inherits `0.25`) | `0.25` | `0.25` → `0.25` |
| 3 | `selection.marquee_color` | `[1, 1, 0, 1]` | absent (inherits `[1, 1, 0, 1]`) | `[1, 1, 0, 1]` | `[1, 1, 0, 1]` → `[1, 1, 0, 1]` |
| 4 | `selection.marquee_width_px` | `1` | absent (inherits `1`) | `1` | `1` → `1` |
| 5 | `selection.double_click_s` | `0.5` | absent (inherits `0.5`) | `0.5` | `0.5` → `0.5` |
| 6 | `terrain.texgen_mode` | `"world_xz"` | absent (inherits `"world_xz"`) | `"world_xz"` | `"world_xz"` → `"world_xz"` |
| 7 | `terrain.m_per_tile` | `2.0` | absent (inherits `2.0`) | `2.0` | `2.0` → `2.0` |
| 8 | `terrain.lighting` | `"donor"` | absent (inherits `"donor"`) | `"donor"` | `"donor"` → `"donor"` |
| 9 | `terrain.alpha_patch_mode` | `"donor_approx"` | absent (inherits `"donor_approx"`) | `"donor_approx"` | `"donor_approx"` → `"donor_approx"` |
| 10 | `terrain.relief_stamps` | `false` | **`true`** (explicit) | **`true`** (explicit) | `true` → `true` — **intentional non-default override, do not revert** |
| 11 | `terrain.tile_diversity` | `true` | absent (inherits `true`) | `true` | `true` → `true` |
| 12 | `water.surface_y` | `-0.25` | absent (inherits `-0.25`) | `-0.25` | `-0.25` → `-0.25` |
| 13 | `water.alpha_confine` | `true` | absent (inherits `true`) | `true` | `true` → `true` |
| 14 | `water.shore_prox` | `false` | absent (inherits `false`) | `false` | `false` → `false` |
| 15 | `weather.snow` | `false` | absent (inherits `false`) | `false` | `false` → `false` |
| 16 | `camera.fov_deg` | `17.27` | absent (inherits `17.27`) | `17.27` | `17.27` → `17.27` |
| 17 | `hud.minimap_size` | `240` | absent (inherits `240`) | `240` | `240` → `240` |
| 18 | `hud.minimap_inset` | `-8` | absent (inherits `-8`) | `-8` | `-8` → `-8` |
| 19 | `hud.minimap_corner` | `"bottom_right"` | absent (inherits `"bottom_right"`) | `"bottom_right"` | `"bottom_right"` → `"bottom_right"` |
| 20 | `render.fog` | `false` | absent (inherits `false`) | `false` | `false` → `false` |
| 21 | `gameplay.fog_of_war` | `false` | absent (inherits `false`) | `false` | `false` → `false` |

Carried honesty labels (from `config.gd:55-56,58,63,71`): `terrain.texgen_mode`,
`terrain.alpha_patch_mode`, `water.surface_y` and `camera.fov_deg` are **PORT
APPROXIMATION / UNVERIFIED**; no donor grounding is claimed by this restoration.
`features.gameplay.fog_of_war` is a distinct key from the pre-existing top-level
`display.fog_of_war`; both remain `false` and neither was otherwise touched.

---

## 4. Validation — variant runner only, two submissions, no re-submit

Queue state at submission: `now_serving = 531`, `next_ticket = 540`, 9 pending,
`godot.lock HELD` (age 105.4 s), max wait 1825.52 s — long FIFO waits are normal
(`RUN_GUIDE.md:101`). Both jobs used `--max-wait 1800`; neither was re-submitted,
skipped, acked or otherwise mutated. No direct `godot` call.

| Ticket | Job id | Command | Result |
|---|---|---|---|
| **540** | `configrestore01-smoke` | `python variant3d\tools\godot_runner.py run --id configrestore01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/config.gd` | wait **851.96 s**, run **18.17 s**, **`ok`**, exit **0**. stdout = Godot 4.7.2 banner only; stderr **0 B** ⇒ **`SCRIPT ERROR == 0`**. Parse/compile check of `config.gd`; not a runtime merge test. |
| **541** | `configrestore01-uitest` | `python variant3d\tools\godot_runner.py run --id configrestore01-uitest --timeout 240 --max-wait 1800 -- --headless --path variant3d -- --ui-test variant3d/uitest.json` | wait **862.52 s**, run **243.77 s**, **`failed`**, exit **1** (timeout 240). stdout = banner only. stderr 47 lines: 3 benign image-as-resource load warnings (`tile_index_atlas.png`, `alpha.png`, `alphavert.png`), the standard flat-root morph `PORT APPROXIMATION` warning, then **`watchdog: wall-clock limit reached, forced exit`** plus exit-time RID/resource noise. **`SCRIPT ERROR == 0`.** |

Artifacts: `variant3d/.godot_queue/results/00000540.json`,
`00000540_configrestore01-smoke/{stdout,stderr}.txt`,
`00000541.json`, `00000541_configrestore01-uitest/{stdout,stderr}.txt`.

### Honest uitest verdict

**No fresh 17/17 was obtained.** The watchdog killed the run at the 240 s wall-clock
limit before the harness wrote its verdict; `stdout` contains no test output and the
stderr contains no assertion failure. The tracked `variant3d/uitest.json` still reads
`"passed": true`, 17/17, but its mtime is **10:51:54**, hours before this job
(12:35) — it is a **stale artifact from an earlier run**, not evidence from ticket
541. Per the ticket rule *no re-submit*, no second job was launched with a longer
timeout. The 17/17 expectation is therefore **UNVERIFIED by this ticket**, not
failed on an assertion and not passed. The timeout is attributed to harness/machine
load (the queue was busy; the same 240 s cap was hit in `MAP_SMALL_01_report.md:152`
for ticket 494), **not** to a config parse error — `SCRIPT ERROR` count is 0 and the
config smoke check passed.

### Gate statement

No gate job (`--self-test`, `assert_clean.py`) was run by this ticket. The integrated
selftest remains red at **28/29 (`build`)** per `RUN_GUIDE.md:57` and
`MAP_SMALL_01_report.md:151`; this is unchanged, not caused by this edit, and was
**not** weakened — no test, threshold, assertion or expected value was touched.

---

## 5. Map size intentionally unchanged (320²)

`gameplay.map_width_tiles/map_height_tiles` remain **320 / 320** and
`map_type: land`. BUILD-STEP-FIX-01 is still diagnosing the known-red 240² `build`
gate (MAP-SMALL-01's best was 28/29; root cause: house visual footprint trapping the
anchor peasant plus the build step's fixed 25 s window — `MAP_SMALL_01_report.md:154-176`).
Re-applying 240² here would knowingly reintroduce a red configuration, so it was
**not** done. A later, separately owned change must land the build-step fix before
240² is reconsidered.

---

## 6. Stale-doc corrections (references only — none of these files was edited)

| Doc / line | Stale claim | Correction for the owning doc worker |
|---|---|---|
| `reports/QA_CONFIGJSON_01.md:44,54,81-85` | "21/21 MATCH" with `terrain.relief_stamps` `false` and map **240 × 240** | Historically accurate for its audit snapshot; today 20/21 leaves still match but #10 is intentionally `true` and the map is **320 × 320**. Annotate, do not rewrite the old audit. |
| `SWARM_BOARD.md:240` | QA-CONFIGJSON-01 row: "21/21 MATCH; `features` sole addition; map 240²" | Add supersession note: restored block present at 320² with `relief_stamps: true` (CONFIG-RESTORE-01). |
| `README.md:105-108,305,353,508` | "21-key `features` object matching all defaults / 21/21 MATCH" | Now 21 keys present, but one intentional non-default override (`relief_stamps: true`); "matching all defaults" is stale. |
| `CONFIG_PIPELINE.md:283,297,321` | "Not landed — no `features` key"; "Defaults exist; the global JSON override does not" | Already flagged stale by QA-CONFIGJSON-01 §5; object exists now. |
| `CONFIG_COUNT_RECONCILED.md:176,209,224,235` | "contains NO `features` object"; "all 21 getters return defaults because there is nothing to merge" | Historical snapshot. The object now exists; 20 leaves equal defaults and one is overridden. |
| `SWARM_BOARD.md:366,370` | QA-CONFIG-01 / CONFIG-COUNT-01 rows: "no `features` object", MAP-SMALL-01 pinged to add it | Mark RESOLVED; ping satisfied by QA-CONFIGJSON-01 then CONFIG-RESTORE-01. |
| `reports/QA_CONFIG_01_getters.md:82,111,126` | F-01 "No `features` object"; "when does CONFIG-JSON-01 land?" | Historical; config-side artifact landed, getters remain unwired by consumers. |
| `reports/RELIEF_ENABLE_01.md:54-72,186-189` | §2 "precondition mismatch", Q1 asks whether a separate ticket should re-add all 21 leaves | **Q1 answered by this ticket**: owner commissioned an explicitly owned restoration at 320², with the relief flag kept on. §2's one-leaf deviation and §7's summary describe the pre-restoration state only. |
| `RUN_GUIDE.md:113,119` | §6 "effective defaults 240×240" | Describes menu defaults, not the shipped config; current `config.json` is 320². Cross-reference needed; out of this ticket's scope. |

`SWARM_BOARD.md:335` already lists `QA-CONFIG-RESTORE-01` as RUNNING; that QA worker
should re-verify the 21 leaves against this report rather than against the stale
"21/21 default MATCH" snapshot.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. **Q1 — fresh uitest verdict.** Should a separately owned ticket re-run
   `configrestore01-uitest` with a longer wall-clock allowance (or on a quiet queue)
   to obtain a real 17/17? This ticket did not re-submit by rule.
2. **Q2 — runtime merge proof.** The smoke job checks parsing only; no job emitted
   `--dump-config` to show all 21 keys resolved from the JSON. `SCRIPT ERROR == 0`
   plus programmatic JSON parity is strong but not a runtime-dump observation.
3. **Q3 — stale-doc ownership.** Which worker applies the §6 annotations? This
   agent owns no doc outside this report.
4. **Q4 — 240² gate.** When BUILD-STEP-FIX-01 lands a green `build` step, should a
   new ticket re-apply 240², and should the restored `features` block stay at the
   same values?
5. **Q5 — relief override documentation.** `features.terrain.relief_stamps: true`
   intentionally deviates from `config.gd:59`. Should the code comment be annotated
   by its owner to say the JSON override is expected, so future audits do not
   "fix" it back to `false`?
6. **Q6 — consumer wiring.** All 21 leaves are now globally configurable in JSON,
   but no consumer reads them yet (`config.gd:42-45`); which tickets wire which
   getters remains outside this scope.

---

## 8. Summary

Restored the complete `features` block in `variant3d/config.json:16-54` from the
21-key template in commit `1d67e32b`, using the exact literals of
`config.gd:46-84`: 8 groups, **21 leaves, 0 missing, 0 extra**; 20 keys equal their
code defaults and `terrain.relief_stamps` stays explicitly `true` so RELIEF-ENABLE-01
is not reverted. JSON parses; every other key is byte-identical (CRLF preserved);
map stays **320 × 320 / land** because the 240² `build` gate is still red.

Pre-edit copy: `inbox/backup/config.json.bak-CONFIGRESTORE` (byte-identical,
SHA-256 `bd80c2d1…48bf0f5`). Validation via variant runner: ticket 540
`configrestore01-smoke` **ok**, exit 0, `SCRIPT ERROR == 0`; ticket 541
`configrestore01-uitest` **failed at the 240 s watchdog**, exit 1, no assertion
failure and no fresh 17/17 (the on-disk 17/17 artifact is stale). No re-submit and
no queue mutation. The 28/29 (`build`) selftest gate remains red and untouched.

**Files edited by this agent:** `variant3d/config.json`, this report, and one backup
artifact. **No other file was edited** — not `config.gd`, `main.gd`, `selftest.gd`,
`game.gd`, any test or fixture, `app/**`, the donor, or any other report/doc. The
runner result artifacts are harness output, not source edits.

*End of CONFIG-RESTORE-01.*
