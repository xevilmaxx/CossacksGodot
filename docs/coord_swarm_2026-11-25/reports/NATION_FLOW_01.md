---
id: NATION-FLOW-01
owner: NATION-FLOW-01 subagent (read-only tracing worker)
date: 2026-11-25
status: complete
scope: "Read-only trace from menu/config through game generation to rendered entity sids. Sole output: this report. No code edits, no runner jobs."
sources_primary:
  - docs/coord_swarm_2026-11-25/reports/CFG_01_skirmish_defaults.md
  - docs/coord_swarm_2026-11-25/reports/DEFAULTS_VERIFY_01.md
  - docs/coord_swarm_2026-11-25/reports/CONFIG_UI_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_CONFIGJSON_01.md
  - variant3d/scripts/menu.gd
  - variant3d/scripts/config.gd
  - variant3d/scripts/data.gd
  - variant3d/scripts/main.gd
  - variant3d/scripts/game.gd
  - variant3d/scripts/world3d.gd
  - variant3d/scripts/world3d_entities.gd
sources_supporting:
  - variant3d/config.json
  - variant3d/assets/models/manifest.json
  - variant3d/assets/models/anim/buildings/buildings.json
  - variant3d/assets/models/anim/land_units/index.json
  - variant3d/assets/models/anim/naval_units/index.json
  - variant3d/scripts/world.gd
  - variant3d/scripts/audio.gd
  - variant3d/scripts/ai.gd
labels: |
  [OBS] read directly from a file/artifact; [DER] derived by following code semantics;
  [INF] inferred from indirect evidence; [UNVERIFIED] not checked by this trace.
parity_claim: none
---

# NATION-FLOW-01 — nation selection → game generation → rendered entity sids

## 1. Question and method

Trace the selected nation (default `rus` vs `bav`) from the skirmish menu and/or config file, through
`main.gd`/`config.gd` application, through `game.setup()` and entity creation, to the `sid`/`def` paired with
each entity and finally to the mesh resolution in `world3d_entities.gd`. Identify the first hop where the nation
value is dropped, defaulted, or collapsed onto a Ukrainian art family. No claim of donor or visual parity is made
anywhere in this report; only code paths and asset-provenance strings are described.

## 2. Sources

Primary reads: the four named reports and the seven named `variant3d/scripts/*.gd` files. Supporting reads used
only to disambiguate the "different key for buildings/ships" question: `variant3d/config.json`,
`variant3d/assets/models/manifest.json`, the three animation/building indices under
`variant3d/assets/models/anim/`, and `variant3d/scripts/{world.gd,audio.gd,ai.gd}`. Line numbers are from the
files as they exist in this worktree today; several line numbers quoted in the older reports are stale after
later commits (e.g. CFG-01 cites `config.gd:75`, the current default is `config.gd:121-122`).

## 3. Hop table — does the nation value survive?

| # | Hop | Evidence (`path:line`) | Value after hop | Survives? | Label |
|---:|---|---|---|---|---|
| 0 | Reported defaults | `CFG_01_skirmish_defaults.md:18-19,81`; `DEFAULTS_VERIFY_01.md:51`; `CONFIG_UI_01.md:36-39`; `QA_CONFIGJSON_01.md:77-85` (config keys/map only) | interactive `rus`/`bav`; overlay `config.json:71-72` `rus`/`bav`; built-in `config.gd:121-122` `rus`/`bav` | yes | [OBS] |
| 1 | Menu state | `variant3d/scripts/menu.gd:21-22` (`nation0 := "rus"`, `nation1 := "bav"`); roster arrays `:30-33`; `_ensure_roster()` fills empty slots from those two ids at `:564-578`; `_sync_legacy()` mirrors roster→legacy at `:543-548`; `_roster_cfg()` writes per-slot `nation` at `:672-680` | `rus` / `bav` in roster and legacy vars | yes | [OBS] |
| 2 | Menu → emitted start config | `_emit_start()` `menu.gd:924-965`: `cfg["nation0"]`/`["nation1"]` at `:925`; roster under `cfg["players"]` at `:955-958`; legacy keys re-mirrored from roster at `:960-962`. Mission/load path emits only legacy keys at `:858` | `cfg.nation0="rus"`, `cfg.nation1="bav"`, `cfg.players[i].nation` per slot | yes | [OBS] |
| 3 | Menu cfg → Data statics | `main.gd:257-260` stores cfg and calls `_apply_menu_cfg()`; `:274-285` reads `n0`/`n1` (fallbacks **`"ukr"`/`"rus"`** at `:275-276`) and prefers roster; `_apply_roster_cfg()` `main.gd:380-414` validates each sid against `Data.NATIONS` (`:396-397`), then writes `Data.PLAYER_NATIONS = nations` at `:410`; legacy path `:418-435` writes `[n0, n1]` at `:432` | `Data.PLAYER_NATIONS = ["rus","bav"]` for the default skirmish | yes, conditional on valid ids | [OBS+DER] |
| 4 | No-menu config overlay | `main.gd:179-181` `cfg.load_all()` + `cfg.apply()`; `config.gd:273-302` merges `DEFAULT` → settings file → `user://options.json`; `config.gd:550-569` reads `gameplay.nation0/nation1` (`:550-551`) or `gameplay.player_nations` (`:555-560`), writes `Data.PLAYER_NATIONS`; overlay values `config.json:71-72` | `["rus","bav"]`; note `config.gd:555-560` does **not** validate against `Data.NATIONS` | yes | [OBS+DER] |
| 5 | `Data` → `game.players[].nation` | `main.gd:1075-1092` creates game and calls `game.setup(start_mode)`; `game.gd:306-315` → `setup_begin()`; `game.gd:373-389` reads `Data.PLAYER_NATIONS` (`:375`, wrong-type fallback `["ukr","rus"]`) and assigns `pl["nation"]` at `:386` (out-of-range fallback `"rus"`); name resolution `_nation_name()` at `:425-432` | P0 `rus`, P1 `bav`, stored on the **player**, not on entities | yes | [OBS+DER] |
| 6 | Player nation → starting entities | `game.gd:2186-2191` `spawn()` stores `sid`, `def = Data.UNITS[sid]/Data.BUILDINGS[sid]`, `player` — **no nation field on the entity**; `_spawn_starts()` `game.gd:2702-2740` spawns literal sids `cen` (`:2710`), `peasant` (`:2721`), `tow`/`cannon` (`:2725-2727`) and `Data.BATTLE_ARMY` sids (`:2733-2739`), with **no** `resolve_sid()` call | `e.sid = "cen"/"peasant"/…` for every nation | **no** (generic sid) | [OBS+DER] |
| 7 | Player nation → trained entities | `game.gd:3973-3979` `train_unit()` reads `players[player].nation` and calls `Data.resolve_sid(nat, sid)`; `data.gd:1563-1567` maps via `NATION_UNITS` (`data.gd:294-305`); captured-nation override `game.gd:3982-3987`; AI path `ai.gd:696-703` uses the same resolver | `rus` → `strelet`/`cossackdon`/`pope`; `bav` → unchanged generic sid (`NATION_UNITS` has no `bav` key) | partial | [OBS+DER] |
| 8 | Sim entities → 3D feed | `world3d.gd:322-358` reconciles `game.entities` and calls `entities.add_unit(e)` / `add_building(e)` using `kind` only; resources `:360-410`; 3D branch substitutes `world3d` for `world.gd` at `main.gd:1101-1104` (2D branch `:1117-1120`) | entity dict including `sid`, `def`, `player`; nation still absent | no change (already gone) | [OBS] |
| 9 | 3D mesh resolution | `world3d_entities.gd:1409-1410` `add_unit()` reads `ed.sid` → `_mesh_info(sid,"unit")`; `:1428-1437` `add_building()` reads `ed.sid` → `_mesh_info(sid,"building")`; `_mesh_info()` `:922-972` picks `assets/models/glb/<sid>.glb` (`:946-957`) then `assets/models/obj/<sid>.obj` (`:958-962`), else donor-bbox proxy (`:963-965`). Tint comes from **player slot**, not nation: `:608-611`, and `:445` says `donor_tint_mapping: "player slot index → donor gKeyColor slot (identity; mercenary slot 12); NOT nation"` | same mesh for all nations for a given sid | **no** | [OBS] |
| 10 | 3D resources / naval | `_resource_sid()` `world3d_entities.gd:1701-1715` derives resource mesh from `type`+position (`_pick_sid` `:1719-1723`), never nation. Ships are units (`data.gd:1209-1210` `yacht` has `naval: true`; `game.gd:474-475` `_is_naval()` reads `def.naval`; `data.gd:1356-1357` dock trains seven ship sids) and go through the same `add_unit()` → `obj/<sid>.obj` path; e.g. `manifest.json:3140-3146` `yacht` → `units/yacht.osm` / `obj/yacht.obj` | sid-only for ships too | **no** | [OBS+DER] |
| 11 | 2D comparison — different keys exist there | `world.gd:457-468` `_anim_key()` reads `Data.PLAYER_NATIONS[player]` and tries `<nat>_<sid>` before bare `sid`; `world.gd:611-626` `_bld_key()` does the same for buildings via `_nation_sheet(..., "buildings", …)`; `world.gd:870-895` `nation_of()`/resolver derive a nation folder from the **sheet filename** (`units`/`buildings`/`naval`); `world.gd:3154-3166` hulls use `kind="naval"` → `common/naval`; `naval_units/index.json` has only bare family keys (`yacht`, `fishboat`, …, `xebec`) | 2D has nation-prefixed unit/building keys and a shared naval family key; 3D has none of them | 2D yes, 3D no | [OBS] |

### Provenance of the generic 3D sids

`variant3d/assets/models/manifest.json` records the donor source path for each baked mesh. The generic sids used
for every nation in hops 6/9 include Ukrainian-donor-derived geometry:

| `sid` | Manifest line | Donor mesh string |
|---|---|---|
| `peasant` | `manifest.json:5-11` | `data\actors\units\peaukr.oss` / `materials\units\peaukr.dds` |
| `cen` | `manifest.json:176-179` | `data\actors\buildings\ukr\ukrcen.osm` / `\ukr\ukrcen.dds` |
| `hou`, `bar`, `sta`, `bla`, `aca`, `art`, `dip` | `manifest.json:195-198,216-219,235-238,254-257,273-276,292-295,3085-3086` | `buildings\ukr\ukr<sid>.osm` / `\ukr\ukr<sid>.dds` |

Nine manifest entries in total contain a `ukr` donor path (the eight above plus `peasant`). The current tree has
172 `.obj` files in `variant3d/assets/models/obj/` and **zero** `.glb` files, so `_mesh_info()` resolves through the
OBJ branch. [OBS]

## 4. Drop-point ranking

Ranked by closeness to the rendered `rus`/`bav` identity. "Drop" means the nation stops influencing the art, not
that the config value was lost.

1. **D1 — 3D mesh key is `sid` only; no nation key exists in the 3D renderer.**
   `world3d_entities.gd:1409-1410`, `:1436-1437`, `:922-972`. All nations requesting `cen` receive the single
   `obj/cen.obj` whose manifest source is `ukrcen.osm` (`manifest.json:178`). Player tint is slot-indexed and
   explicitly "NOT nation" (`world3d_entities.gd:445`, `:608-611`), so it does not compensate. This is the exact
   point where a non-Ukrainian nation is **mapped onto a Ukrainian art family** in 3D. Severity **HIGH** for
   national visual identity. [OBS for code + provenance; INF for the visual consequence]

2. **D2 — starting army never passes through `NATION_UNITS`.**
   `_spawn_starts()` `game.gd:2702-2740` spawns literal generic sids; the only nation-aware resolver is
   `Data.resolve_sid()` (`data.gd:1564-1567`) called from `train_unit()` (`game.gd:3979`), AI (`ai.gd:703,718`)
   and HUD (`hud.gd:783`). `NATION_UNITS` (`data.gd:294-305`) has **no `bav` entry**, so Bavaria keeps generic
   sids even for trained units. Even `rus` starts with generic `serdiuk` rather than `strelet`. This is where the
   nation ceases to affect *entity sids* for the initial army. Severity **HIGH** for unit variety. [OBS+DER]

3. **D3 — conditional Ukrainian defaults on malformed/absent state.**
   `main.gd:275-276` defaults missing `nation0/nation1` to **`ukr`/`rus`**; `main.gd:394-397` falls back to `n0`
   for an unknown roster P0 id (so an invalid P0 can become `ukr`); `game.gd:375` falls back to
   `["ukr","rus"]` when `Data.PLAYER_NATIONS` is not an Array. With the shipped `menu.gd:21-22` and
   `config.json:71-72` values none of these fire. Severity **MEDIUM, conditional**. [OBS+DER]

4. **D4 — config-side roster is accepted without a `Data.NATIONS` check.**
   `config.gd:555-569` copies `gameplay.player_nations` verbatim, unlike the menu path's validation at
   `main.gd:396-397`. A bad sid therefore survives into `game.players[].nation` and silently renders generic art
   (D1/D2) rather than being defaulted. Severity **LOW-MEDIUM**. [OBS+DER]

5. **D5 — naval/building keys differ from unit keys in 2D but not in 3D.**
   2D buildings use `<nat>_<sid>` (`world.gd:611-626`), units use `<nat>_<sid>` (`world.gd:457-468`), ships use
   the shared `common/naval` family with a `yacht` fallback (`world.gd:3150-3166`, `:3174-3184`). 3D collapses
   all three onto `sid` (D1). Buildings additionally have a nation-aware key in the **sim**,
   `game.gd:1674-1678` `_bld_scale_key()` → `bld_rm()`/`bld_block_rect*()` (`:1680-1734`), but that key feeds
   collision footprints, not mesh choice. Severity **MEDIUM** (explains why "nation is present somewhere" can
   look correct while 3D art is not). [OBS]

6. **D6 — adjacent, not an entity-art path: audio fallback.**
   `audio.gd:14-16,80-82` defines `MUSIC_FALLBACK := "ukr"` for unknown nation ids; `main.gd:654` passes
   `game.players[0].get("nation","ukr")`. The current tree does contain `bav.ogg`, so the fallback is likely not
   exercised for the default pair. Listed for completeness, not as a rendered-sid cause. Severity **LOW**.
   [OBS + INF]

### What is observed vs inferred

- **Observed:** menu/config values and emit keys; `Data.PLAYER_NATIONS` writes; `game.players[].nation` writes;
  entity dictionaries containing `sid`/`def` but no nation; 3D `_mesh_info()` keyed by `sid`; manifest paths
  naming Ukrainian donor meshes; absence of a `bav` key in `NATION_UNITS`; 2D nation-first resolvers and shared
  naval family.
- **Derived:** the sequence survives for the default `rus`/`bav` up to `game.players[].nation`; starting sids are
  therefore nation-independent; trained `rus` units can become nation-specific while trained `bav` units cannot.
- **Inferred, not verified by running or viewing anything:** that all nations consequently *look* Ukrainian in
  3D, and that this is undesirable. No screenshot, render, donor comparison or parity claim is made.

## 5. Smallest discriminating probe

One tuple, taken after a skirmish start and after training one unit for each player, separates the competing
hypotheses (bad value at source vs dropped at spawn vs dropped at mesh key):

```
for i in [0, 1]:
  {player: i,
   cfg_nation: cfg.players[i].nation,                 # menu.gd:958 / main.gd:258
   data_nation: Data.PLAYER_NATIONS[i],               # main.gd:410 or config.gd:560/566
   sim_nation: game.players[i].get("nation"),         # game.gd:386
   townhall_sid: <e.sid for first building of player i>,   # game.gd:2190
   trained_sid:  <e.sid of one trained unit of player i>,  # game.gd:3979
   mesh_source:  <info["source"] / resolved obj path for townhall_sid>}  # world3d_entities.gd:946-967
```

Read-only sources for the same discriminating data: `main.gd:197-200` (`--dump-config` prints `cfg.dump()`) for
the config half; `game.serialize()` (`main.gd:1098`) or the test bridge installed at `main.gd:203-207` for the
sim half; `world3d_entities.stats` / `_mesh_sources` (`world3d_entities.gd:416`, `:970-971`) for the mesh half;
`manifest.json` rows for the donor provenance of the resolved sid.

**Interpretation:** if `cfg_nation`/`data_nation`/`sim_nation` are `rus`/`bav` while `townhall_sid == "cen"` and
`mesh_source` resolves to `obj/cen.obj`, the nation is intact through the sim and is dropped at hops 6 and 9 —
not in the menu or config. A `rus_cen`/`bav_cen` sid or a nation-prefixed mesh path would instead implicate an
earlier hop. This probe needs no new runner job to be specified; it is a state read/dump recommendation only and
was **not** executed here.

**Owning file for a fix:** `variant3d/scripts/world3d_entities.gd` is the primary owner (mesh lookup must accept a
nation key or map `sid` → nation asset). Supporting owners: `variant3d/scripts/game.gd` (resolve starting-army
sids through `Data.resolve_sid()`), `variant3d/scripts/data.gd` (add `NATION_UNITS` entries for `bav` if unit
variety is wanted), and `variant3d/assets/models/manifest.json` + `variant3d/assets/models/obj/` if actual
non-Ukrainian building geometry is to be supplied. `menu.gd`, `config.gd`, `main.gd` and `config.json` already
carry `rus`/`bav` correctly and are **not** the fix owners for this flow.

## 6. Open questions

1. Is sid-only 3D geometry an intentional design choice (national variation delivered by 2D sheets/tint only), or
   an unfinished port of the 2D nation-first resolver? No design note in the read set decides this — [UNVERIFIED].
2. Do nation-specific *3D* assets exist outside `manifest.json` (e.g. `anim3d.gd` skins for `rus`/`bav`)? Only
   `EXTRA_ANIM_INDEX` for Scotland was observed (`data.gd:307-322`); a full asset audit was out of scope —
   [UNVERIFIED].
3. Does `user://options.json` on this machine contain `gameplay.player_nations` or nation keys that override the
   overlay (`config.gd:295-301`)? Not inspected here; also flagged in `DEFAULTS_VERIFY_01.md:108` — [UNVERIFIED].
4. Captured foreign town halls push a nation id into `players[capturer].captured_nations` (`game.gd:5606-5614`)
   and can override trained sids (`game.gd:3982-3987`). In 3D the foreign sid still resolves to a generic mesh;
   whether that is desirable was not checked — [INF].
5. The older reports' line numbers are stale after later commits; a future audit should re-cite them. The values
   themselves were corroborated in the current files — [OBS].

## 7. Summary

The nation value `rus` / `bav` survives the whole configuration chain in the current tree: menu defaults
(`menu.gd:21-22`) → emitted `cfg.nation0/nation1` and `cfg.players[].nation` (`menu.gd:925,955-962`) →
`Data.PLAYER_NATIONS` (`main.gd:410`, or `config.gd:550-566` on the no-menu path) → `game.players[].nation`
(`game.gd:386`). It is **not** copied onto entities: `spawn()` stores only `sid`/`def`/`player`
(`game.gd:2186-2191`).

The first functional loss is at starting-army creation (`game.gd:2702-2740`, generic sids) and the decisive one
is in the 3D renderer (`world3d_entities.gd:1409-1410,1436-1437,922-972`): units, buildings and ships all resolve
their mesh from `sid` alone, with no nation key, while the generic `peasant`/`cen`/… meshes are baked from
Ukrainian donor assets (`manifest.json:5-11,176-179`). The 2D layer does have nation-prefixed unit/building keys
and a separate shared naval family (`world.gd:457-468,611-626,3150-3166`), but the 3D branch does not instantiate
that resolver (`main.gd:1101-1104`). Conditional Ukrainian defaults also exist at `main.gd:275-276`,
`main.gd:394-397` and `game.gd:375` for malformed or missing state.

No code was edited, no runner job was launched, and no donor/visual parity claim is made.
