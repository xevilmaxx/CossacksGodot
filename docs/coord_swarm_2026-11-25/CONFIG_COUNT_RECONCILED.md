---
id: CONFIG-COUNT-01
title: "CONFIG-COUNT-01 — reconciled authoritative snapshot of the 21 feature getters (7 vs 13 WIRED)"
date: 2026-11-25
owner: CONFIG-COUNT-01 (read-only reconciliation worker)
status: COMPLETE__RECONCILED__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Exactly one new file: docs/coord_swarm_2026-11-25/CONFIG_COUNT_RECONCILED.md. Read-only on all sources; no code, config, test, asset, backup or runner job was created or edited."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "Current working tree = HEAD 49aa81f7 (2026-11-25 10:55:05 +0100) plus concurrent uncommitted edits by other swarm workers (e.g. SWARM_BOARD.md, selftest.gd, world3d_entities.gd). None of those edits touches config.gd, config.json, or any of the six getter-consuming files; a re-grep at the end of this task returned the same 42-match census. Source call sites and config.json were read from the working tree, not from a stale report."
source_convention: "config.gd = variant3d/scripts/config.gd; config.json = variant3d/config.json; consumer paths = variant3d/scripts/<file>.gd. Report paths are relative to docs/coord_swarm_2026-11-25/ unless printed in full."
label_legend: "observed = literal read with path:line or a directly read report; derived = arithmetic/enumeration/absence proof from observed; inferred = plausible but unproven; UNVERIFIED = no accessible evidence (missing report or runtime probe)."
status_vocabulary: "WIRED / READER_ONLY / UI_ONLY / PENDING as defined in CONFIG_PIPELINE.md §0 — see §0 below. QA-CONFIG-01 used a DIFFERENT vocabulary for READER_ONLY and UI_EMITTED; that is the main source of the apparent conflict."
---

# CONFIG-COUNT-01 — reconciled 21-getter snapshot (7 vs 13 WIRED)

## 0. Snapshot caveat and status vocabulary

**This file is the authority for the CURRENT working-tree state, not for either earlier
report.** Both prior counts were defensible when written:

- `CONFIG_PIPELINE.md` (CONFIG-DOC-01, committed in `49aa81f7`) snapshots the state **before**
  the CONFIG-WIRE-HUD and CONFIG-WIRE-RELIEF call sites entered its view: **7 WIRED /
  2 READER_ONLY / 2 UI_ONLY / 10 PENDING**. Its §2.1 explicitly says getter calls exist in
  only four consumer files; its §5.1 marks HUD and RELIEF `RUNNING`. [observed]
- `reports/QA_CONFIG_01_getters.md` (QA-CONFIG-01, same commit) snapshots the state **after**
  those call sites appeared in `hud.gd` and `main.gd`, but before their reports landed:
  **13 WIRED / 1 PENDING / 1 UI_EMITTED / 6 READER_ONLY**. [observed]

The two reports also **use different status words for the same phenomenon**, so their
numbers are not directly comparable (see §4). This document re-counts every row against
the files as they exist now and freezes **one** vocabulary:

| Status | Definition used in THIS document (inherited from `CONFIG_PIPELINE.md:29-34`) |
|---|---|
| **WIRED** | A typed getter is called from a consuming game file and its value reaches a runtime decision point (shader uniform, geometry, gate). Defaults may be behaviour-identical to the old literal. |
| **READER_ONLY** | The getter is called, but its result only lands in `stats`/audit fields; no shader or behaviour path uses it. |
| **UI_ONLY** | The feature is surfaced in a menu row / emitted into `cfg`, but the namespaced `features.*` getter has **no live runtime consumer**. This includes a getter call that exists only inside an uncalled helper. |
| **PENDING** | The getter and default exist in `config.gd`, but **no consuming file calls the getter at all**. |

Labels are attached per row in §2 and §4. **UNVERIFIED** is used where a report is absent
or a runtime probe was not run; it never upgrades a row to WIRED by itself.

---

## 1. Method — twice-verification and grep census

Every one of the 21 rows was checked twice, independently:

1. **Definition check** — read directly in `FEATURES_DEFAULTS` (`config.gd:46-84`) **and** in
   its typed getter body (`config.gd:420-483`), including the fallback literal. [observed]
2. **Consumer check** — either (a) the call site was read directly at the cited `file:line`
   with context, or (b) absence was proved by an exhaustive grep of every
   `variant3d/scripts/*.gd` for `feature_[a-z_]+`, `"feature_*"` string names, and
   `has_method`/`call` dynamic forms. [observed + derived]

**Grep census (current working tree): 42 literal `feature_` matches.** [derived from grep]

| Bucket | Count | Where |
|---|---:|---|
| Getter definitions | 21 | `config.gd:420,423,426,430,433,436,439,442,445,448,451,454,457,460,463,466,470,473,476,479,482` |
| Comments / false positives | 2 | `data.gd:9` (`core_feature_find`, a decompiler comment), `water3d.gd:33` |
| Direct call lines | 9 | `input_controller.gd:98,99,217,218,224` (5), `water3d.gd:165,166,167` (3), `camera3d.gd:195` (1) |
| Dynamic `has_method`/`call` lines | 10 | `hud.gd:278,279,284,285,290,291` (3 getters), `main.gd:758,759` (1 getter), `world3d_fx.gd:378,379` (1 getter) |

Arithmetic: **21 + 2 + 9 + 10 = 42**. The 19 call lines reference **14 distinct getters**
(5 selection, 1 camera, 3 HUD, 1 relief, 3 water, 1 weather). **7 getters have no call line
at all** (5 terrain + `render.fog` + `gameplay.fog_of_war`). [derived] (`input_controller.gd:777`
calls the local helper `_double_click_s()`, not a getter; it is the downstream consumer of
the `:224` getter call and is not counted as a separate getter call line.)

No concatenated/dynamic getter name (e.g. `"feature_" + x`) exists: a targeted grep for
`["']feature_`, `feature_%` and `+ "feature` returned exactly the 10 dynamic lines above
and nothing else. No `feature_*` reference exists in `variant3d/shaders/*` (0 matches),
and `config.json` has 0 matches for both `features` and `feature_`. [observed + derived]

---

## 2. AUTHORITATIVE 21-row table — current working-tree state

Statuses use the §0 vocabulary. "Getter" line numbers are in `config.gd`.

| # | key | default | getter | consuming file:line or NONE | status | evidence |
|---:|---|---|---|---|---|---|
| 1 | `features.selection.world_epsilon_m` | `0.005` | `feature_selection_world_epsilon_m()` `:420-421` | `input_controller.gd:218` → `_selection_epsilon_m()` | **WIRED** | Def `:48` + getter `:420-421` [observed]; call read directly + grep [observed]; `CONFIG_WIRE_SEL.md` |
| 2 | `features.selection.attack_epsilon_m` | `0.25` | `feature_selection_attack_epsilon_m()` `:423-424` | `input_controller.gd:217` | **WIRED** | Def `:49` + getter `:423-424`; call `:217`; `CONFIG_WIRE_SEL.md` |
| 3 | `features.selection.marquee_color` | `[1,1,0,1]` | `feature_selection_marquee_color()` `:426-428` | `input_controller.gd:98` → `draw_rect` at `:100` | **WIRED** | Def `:50` + getter `:426-428`; call `:98` [observed]; unvalidated Array is a separate risk (QA F-08) |
| 4 | `features.selection.marquee_width_px` | `1` (int) | `feature_selection_marquee_width_px()` `:430-431` | `input_controller.gd:99` (`float(...)`) | **WIRED** | Def `:51` + getter `:430-431`; call `:99` [observed]; consumer fallback `1.0` float — convention drift only |
| 5 | `features.selection.double_click_s` | `0.5` | `feature_selection_double_click_s()` `:433-434` | `input_controller.gd:224` (called `:777`) | **WIRED** | Def `:52` + getter `:433-434`; call `:224` [observed]; `CONFIG_WIRE_SEL.md` |
| 6 | `features.terrain.texgen_mode` | `"world_xz"` | `feature_terrain_texgen_mode()` `:436-437` | **NONE** | **PENDING** | Def `:55` + getter `:436-437` [observed]; exhaustive grep absence proof [derived]; PORT APPROX, eye planes infeasible (`CONFIG_PLAN_01.md:110`) |
| 7 | `features.terrain.m_per_tile` | `2.0` | `feature_terrain_m_per_tile()` `:439-440` | **NONE** | **PENDING** | Def `:56` + getter `:439-440` [observed]; absence proof [derived]; `_copy()` coerces `2.0`→int `2` in raw `data` (QA check d) — getter returns float `2.0` |
| 8 | `features.terrain.lighting` | `"donor"` | `feature_terrain_lighting()` `:442-443` | **NONE** | **PENDING** | Def `:57` + getter `:442-443`; absence proof [derived]; unvalidated mode string |
| 9 | `features.terrain.alpha_patch_mode` | `"donor_approx"` | `feature_terrain_alpha_patch_mode()` `:445-446` | **NONE** | **PENDING** | Def `:58` + getter `:445-446`; absence proof [derived]; tile→patch index UNVERIFIED |
| 10 | `features.terrain.relief_stamps` | `false` | `feature_terrain_relief_stamps()` `:448-449` | `main.gd:758-759` (dynamic) → `dump["relief_stamps"]` gate `:771-772` | **WIRED** ⚠ | Def `:59` + getter `:448-449`; dynamic call read directly [observed]; **report `CONFIG_WIRE_RELIEF.md` absent, smoke UNVERIFIED, board `:218` RUNNING** — see §6 |
| 11 | `features.terrain.tile_diversity` | `true` | `feature_terrain_tile_diversity()` `:451-452` | **NONE** | **PENDING** | Def `:60` + getter `:451-452`; absence proof [derived]; plan proposes different keys (`smoothing_source`/`diversity_top5_target`) |
| 12 | `features.water.surface_y` | `-0.25` | `feature_water_surface_y()` `:454-455` | `water3d.gd:165` → uniform + plane verts (`:270`) | **WIRED** | Def `:63` + getter `:454-455`; call read directly [observed]; `CONFIG_WIRE_WATER.md`; PORT APPROX label intact |
| 13 | `features.water.alpha_confine` | `true` | `feature_water_alpha_confine()` `:457-458` | `water3d.gd:166` → `stats["water_alpha_confine_config"]` `:277` | **READER_ONLY** | Def `:64` + getter `:457-458`; call `:166` + audit sink `:277` read directly [observed]; shader has no uniform (`CONFIG_WIRE_WATER.md:113-117`) |
| 14 | `features.water.shore_prox` | `false` | `feature_water_shore_prox()` `:460-461` | `water3d.gd:167` → `stats["shore_prox_config"]` `:278` | **READER_ONLY** | Def `:65` + getter `:460-461`; call `:167` + audit sink `:278` [observed]; removed multiplier cannot be restored without shader work |
| 15 | `features.weather.snow` | `false` | `feature_weather_snow()` `:463-464` | `world3d_fx.gd:378-379`, inside **uncalled** `set_weather_from_config()` `:366-385` | **UI_ONLY** ⚠ | Def `:68` + getter `:463-464`; dynamic call read directly [observed]; grep proves **one** definition of the helper and **zero** callers [derived]; menu emits `weather`/`weather_value` (`menu.gd:937-938`); `WEATHER-DRIVER-01` RUNNING — §6 |
| 16 | `features.camera.fov_deg` | `17.27` | `feature_camera_fov_deg()` `:466-468` | `camera3d.gd:195` | **WIRED** | Def `:71` + getter `:466-468` (PORT APPROX comment `:467`); call read directly [observed]; `CONFIG_WIRE_CAM.md` |
| 17 | `features.hud.minimap_size` | `240` | `feature_hud_minimap_size()` `:470-471` | `hud.gd:278-279` (`_mm_size`) → `:322`, `:1415` | **WIRED** | Def `:74` + getter `:470-471`; dynamic call + both consumers read directly [observed]; `CONFIG_WIRE_HUD.md` landed (smoke 432, uitest 440 17/17) |
| 18 | `features.hud.minimap_inset` | `-8` | `feature_hud_minimap_inset()` `:473-474` | `hud.gd:284-285` (`_mm_inset`) → `:335`, `:1444` | **WIRED** | Def `:75` + getter `:473-474`; dynamic call + consumers [observed]; `CONFIG_WIRE_HUD.md`; consumer negates to positive edge distance |
| 19 | `features.hud.minimap_corner` | `"bottom_right"` | `feature_hud_minimap_corner()` `:476-477` | `hud.gd:290-291` (`_mm_corner`) → `:1434-1440` | **WIRED** | Def `:76` + getter `:476-477`; dynamic call + anchors [observed]; `CONFIG_WIRE_HUD.md`; **only bottom-right offsets implemented** — non-default corners are a follow-up |
| 20 | `features.render.fog` | `false` | `feature_render_fog()` `:479-480` | **NONE** | **PENDING** | Def `:79` + getter `:479-480`; absence proof [derived]; `FogMode=0` ambiguous (`DENV_01`), plan proposes a nested object instead |
| 21 | `features.gameplay.fog_of_war` | `false` | `feature_gameplay_fog_of_war()` `:482-483` | **NONE** (menu writes `Data.FOG_OF_WAR` `menu.gd:722`, emits `cfg.fog_of_war` `:939`; applied key is `display.fog_of_war` `config.gd:498`) | **UI_ONLY** | Def `:82` + getter `:482-483`; absence proof [derived]; read directly `menu.gd:717-722,939` + `config.gd:498` [observed]; three namespaces (QA F-03) |

**Roll-up — derived from §2:** 21 = **11 WIRED + 2 READER_ONLY + 2 UI_ONLY + 6 PENDING**.
[derived] WIRED = rows 1–5, 10, 12, 16–19. READER_ONLY = 13–14. UI_ONLY = 15, 21.
PENDING = 6–9, 11, 20.

⚠ = row is in flight; see §6. The number **11** can move.

---

## 3. Why the two earlier numbers were both right

The conflict is **two effects at once**, not one:

1. **Time effect (4 rows).** CONFIG-WIRE-HUD (3 rows) and CONFIG-WIRE-RELIEF (1 row) put
   call sites into `hud.gd` and `main.gd` after CONFIG-DOC-01's snapshot but before
   QA-CONFIG-01's audit. CONFIG-DOC-01 counted those 4 as PENDING; QA counted them WIRED.
2. **Vocabulary effect (the remaining 2 of the +6, plus mirror reclassifications).**
   QA counts **any live call site** as WIRED, so it promoted the two water audit-only rows;
   and it uses READER_ONLY for **no call site at all**, where CONFIG-DOC-01 says PENDING.

| Prior report | WIRED | READER_ONLY | UI_ONLY / UI_EMITTED | PENDING | Vocabulary |
|---|---:|---:|---:|---:|---|
| `CONFIG_PIPELINE.md` (CONFIG-DOC-01) | 7 | 2 | 2 UI_ONLY | 10 | READER_ONLY = called but audit-only; PENDING = no call |
| `QA_CONFIG_01_getters.md` (QA-CONFIG-01) | 13 | 6 | 1 UI_EMITTED | 1 | READER_ONLY = no call site; WIRED = any call site |
| **This file (current)** | **11** | **2** | **2 UI_ONLY** | **6** | §0 vocabulary, current files |

The arithmetic bridge is exact:
`7 + 3 (HUD) + 1 (relief) = 11` under a constant vocabulary. QA's `13 = 11 + 2` because
it also counts `water.alpha_confine` and `water.shore_prox` as WIRED. [derived]

---

## 4. The 7→13 delta row by row (crosswalk)

| # | key | CONFIG-DOC-01 | QA-CONFIG-01 | Current | Cause of the difference | Ticket / when |
|---:|---|---|---|---|---|---|
| 1–5 | 5 `selection.*` | WIRED | WIRED | WIRED | none | CONFIG-WIRE-SEL landed before both; report in `49aa81f7` 10:55; board `:188` still stale `RUNNING` |
| 6–9, 11 | 5 `terrain.*` no-call rows | PENDING | READER_ONLY | PENDING | **vocabulary only** (both mean "no call site") | no ticket — CONFIG-RENDER-A still pending (`CONFIG_PLAN_01.md:346`) |
| 10 | `terrain.relief_stamps` | PENDING | WIRED | WIRED ⚠ | **code change**: dynamic call added to `main.gd:758-759` | CONFIG-WIRE-RELIEF; call + `main.gd.bak-CONFIGWIRER` present by QA time; report still absent; board `:218` RUNNING |
| 12 | `water.surface_y` | WIRED | WIRED | WIRED | none | CONFIG-WIRE-WATER landed before both; report in `49aa81f7` |
| 13–14 | `water.alpha_confine`, `water.shore_prox` | READER_ONLY | WIRED | READER_ONLY | **vocabulary only**: QA counts the `water3d.gd:166,167` calls; CONFIG-DOC-01 requires runtime effect | CONFIG-WIRE-WATER; both land in `stats` only (`:277,278`), no shader uniform |
| 15 | `weather.snow` | UI_ONLY | PENDING | UI_ONLY ⚠ | **vocabulary only**: uncalled helper vs menu emission | FX-WEATHER-01 created helper `world3d_fx.gd:366-385`; WEATHER-DRIVER-01 RUNNING, no report |
| 16 | `camera.fov_deg` | WIRED | WIRED | WIRED | none | CONFIG-WIRE-CAM landed before both; report in `49aa81f7` |
| 17–19 | 3 `hud.minimap_*` | PENDING | WIRED | WIRED | **code change**: dynamic helpers added `hud.gd:276-292` + 6 geometry sources | CONFIG-WIRE-HUD; call sites present at QA time, **report landed** by current state (`CONFIG_WIRE_HUD.md`), board `:190` DONE |
| 20 | `render.fog` | PENDING | READER_ONLY | PENDING | **vocabulary only** (no call site) | no ticket — CONFIG-ENV / shader still pending |
| 21 | `gameplay.fog_of_war` | UI_ONLY | UI_EMITTED | UI_ONLY | **vocabulary only** (both describe the menu's `cfg` mirror) | CONFIG-UI-01 landed `0628b3cf` 10:39; report in `49aa81f7`; board `:184` stale RUNNING |

### 4.1 Code-change chronology (which ticket changed which rows and when)

All timestamps are commit times from `git log --date=iso`; commits are generic `step`
batches, so a commit can carry several concurrent lanes. [observed]

| Commit / time | Ticket(s) | Rows affected | Effect |
|---|---|---|---|
| `b1332b91` 2026-11-25 10:31:17 | FX-WEATHER-01 (world3d_fx.gd +144), RELIEF-01, MMJUMP-01 | none of the 21 became WIRED; created the dormant weather helper infrastructure | row 15 stays UI_ONLY/PENDING |
| `0628b3cf` 2026-11-25 10:39:10 | **CONFIG-CORE-01** (`config.gd` +116), CONFIG-PLAN-01, CONFIG-UI-01 (`menu.gd` +38) | **all 21** getters/defaults created; row 21 gains menu emission | at this instant all 21 are PENDING except row 21 UI_ONLY |
| between `0628b3cf` and QA audit (same morning) | **CONFIG-WIRE-SEL / -CAM / -WATER** | rows 1–5, 12–14, 16 | 9 rows gain live call sites → CONFIG-DOC-01's 7 WIRED + 2 READER_ONLY |
| CONFIG-DOC-01 authoring moment (before HUD/RELIEF edits) | — | rows 17–19, 10 still PENDING | snapshot 7 / 2 / 2 / 10 |
| after CONFIG-DOC-01, before QA audit | **CONFIG-WIRE-HUD** (`hud.gd` +65), **CONFIG-WIRE-RELIEF** (`main.gd` +13) | rows 17–19, row 10 | +4 call-site rows → QA's 13 WIRED (with its vocabulary, +2 water = 13) |
| `49aa81f7` 2026-11-25 10:55:05 | all above reports committed together, incl. `CONFIG_WIRE_HUD.md`, `QA_CONFIG_01_getters.md`, `CONFIG_PIPELINE.md` | — | HUD report now landed; RELIEF and WEATHER-DRIVER reports still absent |
| **current working tree** | CONFIG-COUNT-01 (this file) | all 21 re-counted | **11 / 2 / 2 / 6** |

The user-supplied context is confirmed: CONFIG-WIRE-HUD, CONFIG-WIRE-RELIEF and
WEATHER-DRIVER were landing concurrently; only the first of the three has a landed report.
[observed]

---

## 5. `config.json` state and what it means for runtime getter values

**`variant3d/config.json` contains NO `features` object.** [observed — direct read + two
greps: 0 matches for `features`, 0 for `feature_`; corroborated by `CONFIG_PIPELINE.md:286`,
`QA_CONFIG_01_getters.md:82` (F-01), `CONFIG_WIRE_HUD.md:124-126`, `DEFAULTS_VERIFY_01.md:41`]

Consequences at runtime [derived from `config.gd:89,273-302,387-406`]:

1. `DEFAULT.features = FEATURES_DEFAULTS` (`config.gd:89`) seeds all 21 values on
   `load_all()` (`:274`). The JSON overlay (`:276-281`) has nothing to merge for them.
2. Every getter uses `value()/num()/flag()/text()` with the same literal fallback as its
   `FEATURES_DEFAULTS` entry (`:387-406`, `:420-483`). Thus **all 21 getters return exactly
   the code defaults today**, whether a config file loads or not.
3. `user://options.json` is merged **last** (`:295-301`), but the menu writes
   `weather`/`weather_value`/`fog_of_war`/`season_enum` (`menu.gd:936-939`) — **no
   `features.*` key**. So there is currently no JSON or UI path that changes any of the
   21 values.
4. Therefore "WIRED" here means **the getter value reaches the runtime code path**, not
   that a user can tune it. Even the 11 WIRED rows are running at hard-coded defaults.
   Enabling real global configurability requires the `CONFIG-JSON-01` ticket (QA §5),
   which is blocked behind `config.json` ownership. [derived / inferred]

No runner job was launched to prove a non-default getter value at runtime; all cited smoke
jobs were `--check-only` parse checks. [observed; `CONFIG_PIPELINE.md:302-305`]

---

## 6. Rows still in flight — the count can move

| Row(s) | In-flight ticket | Board state | Current evidence | How the number can move |
|---|---|---|---|---|
| 10 `terrain.relief_stamps` | CONFIG-WIRE-RELIEF | `SWARM_BOARD.md:218` **RUNNING** | call site `main.gd:758-759` + backup present; report `CONFIG_WIRE_RELIEF.md` **absent** | If the gate is reverted, 11 → **10 WIRED**; if the report lands, status stays WIRED but UNVERIFIED clears |
| 15 `weather.snow` | WEATHER-DRIVER-01 | `SWARM_BOARD.md:219` **RUNNING** | helper `world3d_fx.gd:366-385` has **zero callers** (grep proof) | When a caller lands, 2 UI_ONLY → **1**, WIRED 11 → **12** (or 13 if QA's water vocabulary is used) |
| 21 `gameplay.fog_of_war` | CONFIG-FOG-01 (proposed, not a ticket) | no board row | three namespaces (QA F-03) | A namespace decision could make the getter live (UI_ONLY→WIRED) or remove it from the schema (21-row table shrinks) |
| 19 `minimap_corner` | HUD follow-up inside CONFIG-WIRE-HUD | report landed | only bottom-right offsets implemented (`CONFIG_WIRE_HUD.md:72-76`) | Status stays WIRED; **effectiveness** of non-default values remains incomplete |
| all 21 | CONFIG-JSON-01 (new) | no board row | no `features` object in `config.json` | Adds tunability, does **not** change the 11/2/2/6 status split unless consumers change |
| board accuracy | COORD board sync | `SWARM_BOARD.md:184,188` still say RUNNING for landed CONFIG-UI-01 / CONFIG-WIRE-SEL; `:220` and `:223` both list CONFIG-DOC-01 (RUNNING / DONE) | reports + source files are authoritative | Board-only status reads will keep disagreeing with this file until COORD syncs it |

Until these land, **11 is the honest WIRED count**; the closest upper bound in flight is
**12** (weather driver only) or **13** if the two water audit-only rows are reclassified as
WIRED under QA-CONFIG-01's vocabulary. [derived / inferred]

---

## 7. Open questions

1. Will `CONFIG_WIRE_RELIEF.md` land, or will the `main.gd` gate be reverted? Row 10's WIRED status rests on a call site with no report. [UNVERIFIED]
2. Will WEATHER-DRIVER-01 call `set_weather_from_config()` from `main.gd`/`world3d.gd`, and will the contract be `cfg.weather` (string) or `cfg.weather_value` (40/70)? (QA §6 Q5) [UNVERIFIED]
3. Which `fog_of_war` namespace wins: `display.fog_of_war`, `features.gameplay.fog_of_war`, or the menu's top-level bool? (QA §6 Q4) [UNVERIFIED]
4. Are the shipped 21 `features.*` names canonical, or will `CONFIG_PLAN_01`'s proposed names be adopted with a migration? Both earlier reports recommend "shipped names". [inferred]
5. Who inherits `config.json` ownership after MAP-SMALL-01, and when does CONFIG-JSON-01 add the `features` object? [UNVERIFIED]
6. Should `alpha_confine`/`shore_prox` become live shader switches, or remain permanent READER_ONLY audit fields? [UNVERIFIED]
7. Will the stale SWARM_BOARD entries (`:184,188,220,223`) be synced to the landed reports? [UNVERIFIED]

---

## 8. Summary

- **Authoritative current snapshot: 21 keys = 11 WIRED / 2 READER_ONLY / 2 UI_ONLY / 6 PENDING.** [derived from §2]
- The **7** in `CONFIG_PIPELINE.md` and the **13** in `QA_CONFIG_01_getters.md` are both correct for their moments: **+3 HUD rows + 1 relief row** are real code changes (CONFIG-WIRE-HUD, CONFIG-WIRE-RELIEF); **+2 water rows** are a vocabulary difference (QA counts a call site even when the value only reaches `stats`); the mirrored labels account for the other 4 rows. [observed + derived]
- Rows 17–19 (HUD) now have a **landed report** (`CONFIG_WIRE_HUD.md`, smoke + uitest 17/17); row 10 (relief) and row 15 (weather) are still in flight and carry ⚠. [observed]
- **`config.json` has no `features` object** — all 21 getters return their `config.gd` defaults at runtime, and no menu row writes a `features.*` key. [observed + derived]
- Every row was verified twice: definition in `FEATURES_DEFAULTS` + getter body, and either a directly read call site or an exhaustive grep absence proof over all `variant3d/scripts/*.gd`. [observed + derived]
- **This task produced this file only** — no code, config, test, asset, backup or runner job was created or edited. [observed]
