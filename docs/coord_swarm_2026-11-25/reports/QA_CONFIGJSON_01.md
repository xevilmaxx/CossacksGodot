---
id: QA-CONFIGJSON-01
title: "QA-CONFIGJSON-01 — verify variant3d/config.json new `features` section against all 21 config.gd defaults"
owner: QA-CONFIGJSON-01 (read-only QA worker)
date: 2026-11-25
scope: "Read-only. Sources: variant3d/scripts/config.gd (FEATURES_DEFAULTS :46-84, getter block :414-483), variant3d/config.json (full read), inbox/backup/config.json.bak-CFGJSON, SWARM_BOARD.md, CONFIG_COUNT_RECONCILED.md, CONFIG_PIPELINE.md, reports/QA_CONFIG_01_getters.md. Sole output: docs/coord_swarm_2026-11-25/reports/QA_CONFIGJSON_01.md. No code/config/backup edit, no runner job."
verification: "JSON parsed with python 3.14 json.load(); 21 leaf values compared to config.gd defaults programmatically (0 mismatches); current config.json deep-diffed against backup config.json.bak-CFGJSON with the new `features` key removed (identical); map dimensions/map_type read directly."
labels: "observed = read directly from file; derived = computed from two observed sources; inferred = reasoned consequence; UNVERIFIED = not checked by this audit."
---

# QA-CONFIGJSON-01 — `config.json` `features` section verification

## 1. Sources

| Source | Lines / role | Label |
|---|---|---|
| `variant3d/scripts/config.gd` | `:42-84` CONFIG-CORE-01 comment + `FEATURES_DEFAULTS` (21 leaves in 8 groups); `:88-89` `DEFAULT.features = FEATURES_DEFAULTS`; `:414-483` typed getter block (21 getters) | observed |
| `variant3d/config.json` | full read (872 lines). New top-level `"features"` object at `:16-54`; gameplay map keys at `:80-81`, `:112` | observed |
| `inbox/backup/config.json.bak-CFGJSON` | full read of pre-change state; **no** `features` key; used as diff baseline | observed |
| `SWARM_BOARD.md` | `:254` QA-CONFIG-01 state ("no `features` object in config.json"); `:258` CONFIG-COUNT-01 state ("`config.json` has NO `features` object") | observed |
| `CONFIG_COUNT_RECONCILED.md` | `:176-194` explicit "config.json contains NO features object" claim + runtime consequences | observed |
| `reports/QA_CONFIG_01_getters.md` | `:126` "Main inconsistencies: no `features` object in `config.json`"; `:111` open question "when does CONFIG-JSON-01 land?" | observed |
| `CONFIG_PIPELINE.md` | `:298` "Defaults exist; the global JSON override does not" | observed |

Tooling: `python` 3.14 (Windows), `json.load` + a deep recursive diff. No file was written except this report. [observed]

---

## 2. 21-row verification table

Dotted keys are under the new top-level `features` object (`features.<group>.<key>`). "config.gd default" is the literal in `FEATURES_DEFAULTS` (`:46-84`); "JSON value" is the parsed value at `config.json:16-54`. Getter names are from `config.gd:420-483`.

| # | Dotted key (features.*) | config.gd default | JSON value | Result | Getter name |
|---|---|---|---|---|---|
| 1 | `selection.world_epsilon_m` | `0.005` | `0.005` | MATCH | `feature_selection_world_epsilon_m` |
| 2 | `selection.attack_epsilon_m` | `0.25` | `0.25` | MATCH | `feature_selection_attack_epsilon_m` |
| 3 | `selection.marquee_color` | `[1, 1, 0, 1]` | `[1, 1, 0, 1]` | MATCH | `feature_selection_marquee_color` |
| 4 | `selection.marquee_width_px` | `1` | `1` | MATCH | `feature_selection_marquee_width_px` |
| 5 | `selection.double_click_s` | `0.5` | `0.5` | MATCH | `feature_selection_double_click_s` |
| 6 | `terrain.texgen_mode` | `"world_xz"` | `"world_xz"` | MATCH | `feature_terrain_texgen_mode` |
| 7 | `terrain.m_per_tile` | `2.0` | `2.0` | MATCH | `feature_terrain_m_per_tile` |
| 8 | `terrain.lighting` | `"donor"` | `"donor"` | MATCH | `feature_terrain_lighting` |
| 9 | `terrain.alpha_patch_mode` | `"donor_approx"` | `"donor_approx"` | MATCH | `feature_terrain_alpha_patch_mode` |
| 10 | `terrain.relief_stamps` | `false` | `false` | MATCH | `feature_terrain_relief_stamps` |
| 11 | `terrain.tile_diversity` | `true` | `true` | MATCH | `feature_terrain_tile_diversity` |
| 12 | `water.surface_y` | `-0.25` | `-0.25` | MATCH | `feature_water_surface_y` |
| 13 | `water.alpha_confine` | `true` | `true` | MATCH | `feature_water_alpha_confine` |
| 14 | `water.shore_prox` | `false` | `false` | MATCH | `feature_water_shore_prox` |
| 15 | `weather.snow` | `false` | `false` | MATCH | `feature_weather_snow` |
| 16 | `camera.fov_deg` | `17.27` | `17.27` | MATCH | `feature_camera_fov_deg` |
| 17 | `hud.minimap_size` | `240` | `240` | MATCH | `feature_hud_minimap_size` |
| 18 | `hud.minimap_inset` | `-8` | `-8` | MATCH | `feature_hud_minimap_inset` |
| 19 | `hud.minimap_corner` | `"bottom_right"` | `"bottom_right"` | MATCH | `feature_hud_minimap_corner` |
| 20 | `render.fog` | `false` | `false` | MATCH | `feature_render_fog` |
| 21 | `gameplay.fog_of_war` | `false` | `false` | MATCH | `feature_gameplay_fog_of_war` |

Group counts: `selection` 5, `terrain` 6, `water` 3, `weather` 1, `camera` 1, `hud` 3, `render` 1, `gameplay` 1 — total **21 leaves / 8 groups**. [observed + derived]

Results: **21 MATCH, 0 MISMATCH, 0 MISSING, 0 EXTRA.** Programmatic comparison (21 defaults encoded from `config.gd:46-84` vs 21 leaves parsed from JSON) returned `mismatches: []`, `extra: []`, `ALL 21 MATCH`. [derived]

Notes (not mismatches):
- The JSON `features` object contains **only** the 21 keys; no extra group or leaf was added. [observed]
- `features.camera.fov_deg` is annotated `PORT APPROX / UNVERIFIED (RV-CAM-01)` in `config.gd:71,467`; its value parity here is observed, but its donor grounding remains UNVERIFIED by this audit.
- `features.terrain.m_per_tile` is written as `2.0` in JSON; the already-documented `_copy()` whole-float→int coercion issue (`QA_CONFIG_01_getters.md:74`) is out of scope here and unchanged. [observed / inherited finding]

---

## 3. Integrity checks

### 3.1 JSON parses
`json.load()` on `variant3d/config.json` succeeded (872 lines). [observed]

### 3.2 No existing key changed
Deep diff of current `config.json` vs `inbox/backup/config.json.bak-CFGJSON`, after removing only the new `features` key from the current document:

- `EQUAL excluding features: True` — every pre-existing key, value, ordering-independent mapping and list is byte-equivalent at the parsed-value level. [derived]
- Backup top-level keys: `['_readme', 'display', 'camera', 'gameplay', 'economy', 'ai', 'audio', 'controls', 'names', 'units', 'buildings']`; current adds exactly one key, `features`. [observed]
- Backup has **no** `features` key; current has it, with 21 leaves. [observed]

### 3.3 Map size and type
- `gameplay.map_width_tiles = 240` (`config.json:80`) [observed]
- `gameplay.map_height_tiles = 240` (`config.json:81`) [observed]
- `gameplay.map_type = "land"` (`config.json:112`) [observed]

→ Map is still **240 × 240 tiles**, type **`land`**. [derived]

---

## 4. Verdict on the earlier "config.json has NO features object" claim

**RESOLVED (stale — no longer true).** [observed + derived]

Evidence:
- `variant3d/config.json:16-54` now contains a top-level `"features"` object with all 8 groups and 21 leaves; `json.load` confirms `features present in current: True`. [observed]
- `SWARM_BOARD.md:254` (QA-CONFIG-01) and `:258` (CONFIG-COUNT-01), `CONFIG_COUNT_RECONCILED.md:176`, `CONFIG_PIPELINE.md:298`, and `reports/QA_CONFIG_01_getters.md:126` all state there is no `features` object / no global JSON override. Those statements were accurate at their audit time but are contradicted by the file on disk now. [observed]
- The change is additive only: the backup (`config.json.bak-CFGJSON`) has no `features`, and removing `features` from the current file reproduces the backup exactly (§3.2). So the "no features object" state moved to "features object present, all 21 defaults mirrored" — matching what CONFIG-COUNT-01's consequence note anticipated for `CONFIG-JSON-01`. [derived / inferred]

The older claim should not be read as a current fact; it is a historical snapshot. The runtime consequence described in `CONFIG_COUNT_RECONCILED.md:180-194` ("all 21 getters return exactly the code defaults today" because there is nothing to merge) still holds **numerically** — because the JSON now mirrors those same 21 defaults — but the mechanism changed: a `features` object is now present and merged through `value()/num()/flag()/text()`; it simply overrides nothing yet because every value equals its default. [inferred from `config.gd:387-406,420-483` + observed parity]

---

## 5. Corrections to stale docs

Read-only audit — no edits made. Recommended follow-ups (owner: COORD / README-UPDATE-02):

| Doc / line | Stale text | Suggested correction | Label |
|---|---|---|---|
| `SWARM_BOARD.md:254` | QA-CONFIG-01 state ends "no `features` object in config.json" | Append: superseded by QA-CONFIGJSON-01 — `features` object now present with 21 matching keys | observed |
| `SWARM_BOARD.md:258` | CONFIG-COUNT-01 "**`config.json` has NO `features` object** → all getters return defaults ... MAP-SMALL-01 pinged to add it" | Mark RESOLVED by QA-CONFIGJSON-01: object added, 21/21 match; MAP-SMALL-01 ping satisfied | observed |
| `CONFIG_COUNT_RECONCILED.md:176` | "**`variant3d/config.json` contains NO `features` object.** [observed ...]" | Annotate as historical snapshot; current state verified present by this report | observed |
| `CONFIG_COUNT_RECONCILED.md:181-182` | "The JSON overlay ... has nothing to merge for them" | Now has a `features` overlay; it merges 21 keys, each equal to its default | derived |
| `CONFIG_PIPELINE.md:298` | "**Defaults exist; the global JSON override does not.**" | Global JSON override now exists; no value deviates from default | observed |
| `reports/QA_CONFIG_01_getters.md:126` | "Main inconsistencies: no `features` object in `config.json`" | Historical; resolve via QA-CONFIGJSON-01 (do not silently rewrite the old audit — annotate) | observed |
| `reports/QA_CONFIG_01_getters.md:111` | open question "when does CONFIG-JSON-01 land?" | This QA confirms the config-side artifact landed; wiring/ownership question remains open | inferred |

`LINKS_01.md:360` already flags a general "stale-status" drift class (DOC-STALE-STATUS-01); these entries fit that ticket. [observed]

---

## 6. Open questions

1. Does the presence of a fully default-mirroring `features` object change any runtime value? Numerically no (§4), but no runner job was launched to prove a non-default getter value at runtime — UNVERIFIED here. [inferred / inherited from `CONFIG_COUNT_RECONCILED.md:196`]
2. Who owns `variant3d/config.json` now that the `features` section has landed (QA-CONFIG-01 §6 Q1)? [inherited open question]
3. Should stale docs be annotated in place or corrected in a new reconciliation pass? This audit recommends annotation, preserving historical snapshots. [inferred]
4. `features.terrain.m_per_tile: 2.0` parity is exact in JSON, but the documented `_copy()` int coercion remains; does JSON merging bypass or reintroduce it? UNVERIFIED by this audit. [inherited]
5. `features.camera.fov_deg = 17.27` donor grounding (RV-CAM-01) is still UNVERIFIED; this audit proves only JSON/config.gd parity. [inherited]

---

## 7. Summary

- `variant3d/config.json` parses cleanly and now contains a top-level `features` object (`:16-54`) with **21 leaves across 8 groups**, matching `FEATURES_DEFAULTS` (`config.gd:46-84`) **21/21 — 0 MISMATCH, 0 MISSING, 0 EXTRA**. [observed + derived]
- Every pre-existing key is unchanged: deep diff vs `config.json.bak-CFGJSON` excluding `features` is identical; `features` is the sole addition. [derived]
- Map remains **240 × 240**, `map_type: land`. [observed]
- The earlier "config.json has NO `features` object" claim (CONFIG_COUNT_RECONCILED / QA-CONFIG-01) is **RESOLVED / stale** — still found in several docs but contradicted by the file on disk. [observed]
- No code, config, backup, or other report was edited; no runner job was launched. Sole output: this report. [observed]
