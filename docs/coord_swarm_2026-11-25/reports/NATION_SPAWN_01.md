---
id: NATION-SPAWN-01
owner: NATION-SPAWN-01 subagent (read-only planning worker)
date: 2026-11-25
status: complete
scope: "Read-only planning of nation-aware spawn / trained-unit sid resolution in game.gd. Sole output: this report. No code edits, no runner jobs, no selftest/uitest changes."
sources_primary:
  - docs/coord_swarm_2026-11-25/reports/NATION_FLOW_01.md
  - docs/coord_swarm_2026-11-25/reports/NATION_DONOR_01.md
  - variant3d/scripts/game.gd
  - variant3d/scripts/data.gd
sources_supporting:
  - variant3d/scripts/world3d_entities.gd
  - variant3d/scripts/selftest.gd
  - variant3d/scripts/uitest.gd
  - variant3d/scripts/testbridge.gd
  - variant3d/scripts/main.gd
  - variant3d/assets/models/manifest.json
labels: |
  [OBS] read directly from a file/artifact; [DER] derived by following code semantics;
  [INF] inferred from indirect evidence; [UNVERIFIED] not checked by this pass.
  Every major claim below carries one of these labels inline.
sources_status:
  NATION_FLOW_01: landed 2026-11-25 11:58 (delivered)
  NATION_DONOR_01: landed 2026-11-25 12:06 after this task began; read in full
  NATION_DATA_01: NOT landed at write time (board shows RUNNING at SWARM_BOARD.md:307) - UNVERIFIED
parity_claim: none
---

# NATION-SPAWN-01 — plan nation-aware spawn/trained-unit sid resolution in `game.gd`

## 1. Sources and scope discipline

Read in full: `NATION_FLOW_01.md` and `NATION_DONOR_01.md` (the latter landed while this pass was running; it was re-read and is incorporated in §2–§4). Read-only source reads: the spawn/train/setup paths of `variant3d/scripts/game.gd`, the resolver and tables in `variant3d/scripts/data.gd`, the NATION-MODEL-01 mesh path in `variant3d/scripts/world3d_entities.gd`, the two test drivers `selftest.gd`/`uitest.gd`, the dump hooks in `main.gd`/`testbridge.gd`, and the relevant `manifest.json` rows. `NATION_DATA_01.md` was **not** on disk at write time (board: `SWARM_BOARD.md:307` still RUNNING) — anything attributed to it is **[UNVERIFIED]** [OBS on absence]. [OBS]

Line numbers are from the current worktree. The line numbers quoted in `NATION_FLOW_01.md` for `game.gd` (`:2186-2191`, `:2702-2740`, `:3973-3979`) were re-confirmed unchanged; the line numbers it quotes for `world3d_entities.gd` (`:922-972`, `:1409-1410`) are **stale** because NATION-MODEL-01 has since landed there — current equivalents are cited in §2 hop 8/9. [OBS]

No donor binary was run, no donor bytes copied, no code/asset/config/test/board file edited. No donor-vs-port visual or model **parity is claimed** anywhere in this report; the word "art" below means "an on-disk mesh/texture whose sid matches a resolved unit sid", not "visually matches the donor". [OBS]

## 2. Data-flow trace (nation value → entity sid → rendered mesh)

| # | Hop | Evidence (`path:line`) | Value after hop | Nation survives? | Label |
|---:|---|---|---|---|---|
| 1 | Config/menu hand-off | `variant3d/config.json:71-72` (`rus`/`bav`); `main.gd:281-285` roster path; `:410` writes `Data.PLAYER_NATIONS` | `["rus","bav"]` | yes | [OBS] (corroborated `NATION_FLOW_01.md:57-62`; `NATION_DONOR_01.md:173-177`) |
| 2 | Player object gets nation | `game.gd:373-389`, specifically `:386` `pl["nation"] = str(pns[i]) if i < pns.size() else "rus"`; wrong-type fallback `["ukr","rus"]` at `:375` | `players[0].nation="rus"`, `players[1].nation="bav"` | yes | [OBS] |
| 3 | Spawn setup runs after players exist | `game.gd:414-419` `setup_spawns()` → `_ensure_start_slots()` → `_spawn_starts()` | nation already set at hop 2 before any spawn | yes | [DER] (ordering in `:380-389` vs `:414-419`) |
| 4 | `spawn()` stores no nation | `game.gd:2186-2197`: entity dict keys `id/kind/player/sid/def/pos/hp/...`; `sid` stored verbatim at `:2190`, `def` at `:2187-2188`; no `nation` key | `e.sid` = whatever caller passed | nation absent from entity | [OBS] (`NATION_FLOW_01.md:63,194-195`; `NATION_DONOR_01.md` G2 `:182`) |
| 5 | Starting army: literal generic sids | `game.gd:2702-2740`: `cen` `:2710`, `peasant` `:2721`, `tow` `:2725`, `cannon` `:2727`; `Data.BATTLE_ARMY` loop `:2733-2740` spawns `pikeman/serdiuk/archer/cossack/officer/cannon` (`BATTLE_ARMY` defined `data.gd:1561`). Only runs when `battle_mode or mult > 0` (`:2729`). **No `resolve_sid()` call.** | same generic sid for `rus` and `bav` | **no** — first functional loss | [OBS] (`NATION_FLOW_01.md:102` D2) |
| 6 | Trained units: already resolved | `game.gd:3973-3979`: `nat` read from `players[player].get("nation","")` `:3976`, fallback `Data.PLAYER_NATIONS[player]` `:3977-3978`, `rsid := Data.resolve_sid(nat, sid)` `:3979`; captured-nation override `:3982-3987`; queue stores `rsid` at `:4039` and `:4048`; completion spawns `job.sid` at `:5492-5499` | `rus`: `serdiuk→strelet`, `cossack→cossackdon`, `priest→pope`; `bav`: identity | partial (data-limited) | [OBS] (`NATION_FLOW_01.md:64`; `NATION_DONOR_01.md` G1 `:181`) |
| 7 | Resolver and its fallback | `data.gd:1563-1567` `resolve_sid`: `NATION_UNITS.get(nat,{})` `:1565`, `m.get(sid,sid)` `:1566`, `return r if UNITS.has(r) else sid` `:1567`. `NATION_UNITS` `data.gd:294-305` has `rus/ukr/pol/tur/alg/swe/sco` keys, **no `bav`**. `UNITS` rows exist for `strelet` `:823`, `cossackdon` `:1059`, `pope` `:1010`. | no mapping or missing unit ⇒ original sid | fallback identity by construction | [OBS] |
| 8 | Mesh sid already nation-aware, read-only | NATION-MODEL-01: `world3d_entities.gd:646-671` `_nation_of()` recovers nation from (1) `ed["nation"]`, (2) `game.players[player]["nation"]` `:659-665`, (3) `Data.PLAYER_NATIONS[player]` `:666-670`; `:695-739` `_entity_mesh_sid()` calls `Data.resolve_sid(nation, base_sid)` `:713` and probes `OBJ_DIR+stem+".obj"` / GLB `:676-680`, `:730-735`; `add_unit()` `:1536-1559` and `add_building()` `:1584-1599` call it before `_mesh_info()`. | renderer can pick a nation mesh **without** an entity `nation` field | nation present in renderer | [OBS] (supersedes `NATION_FLOW_01.md:66,90-95` D1) |
| 9 | Mesh load / art-exists fallback | `world3d_entities.gd:1049-1099` `_mesh_info()` keys only on `sid`/`kind` `:1050`; GLB `:1073-1084`, OBJ `:1085-1089`, else donor-bbox proxy `:1072,:1090-1091`; source recorded at `:1097-1098`. No `rus_`/`bav_` prefixed stems exist (`NATION_DONOR_01.md` G4/G6 `:184-186`). | resolved-stem mesh if on disk, else base sid mesh / proxy | art availability decides, not sim sid | [OBS] |
| 10 | Donor truth on units | `NATION_DONOR_01.md` §2.2, §3 R1 (`:88-93`, `:160`): donor encodes nation identity **in the unit sid** (`pikemanrus`, `strelet`, `pearus` for rus; `musketeer18bav`, `grenadierbav`, `peaaus` for bav); no runtime skin swap (R5 `:164`). Port manifest has `strelet`/`cossackdon`/`pope` but **not** `pikemanrus`/`officerrus`/`pearus` (G9 `:189`) nor either bav-unique unit (G8 `:188`). | sid resolution is the correct mechanism; mapped art is partial | — | [OBS] (donor report), [INF] (design interpretation) |

**Trace conclusion.** The nation value reaches `game.players[].nation` (hop 2) and is even recoverable by the renderer (hop 8). The remaining sim-side gap is **hop 5 only**: `BATTLE_ARMY` starting units bypass `Data.resolve_sid()`, while trained units (hop 6) already use it. Making hop 5 nation-aware brings sim sids in line with hop 6 and with what hop 8 already selects; it does **not** require adding a nation field to entities, and it does **not** supply missing art. [DER] from hops 2–9; consistent with `NATION_FLOW_01.md:167-172` (which named `game.gd` as a supporting fix owner) and `NATION_DONOR_01.md:194-198`.

## 3. Minimal plan (exact change, one file)

**Owner file:** `variant3d/scripts/game.gd`. No other file is edited by this ticket. [DER]

### 3.1 Where the nation value is available at spawn time

`players[player]["nation"]` is written in `setup_begin()` at `game.gd:386` and `setup_spawns()` calls `_spawn_starts()` at `game.gd:414-419`, so it is already populated for every spawn in `_spawn_starts()`. The identical two-source lookup used by `train_unit()` (`game.gd:3976-3979`) is available: primary `players[player].get("nation","")`, fallback `Data.PLAYER_NATIONS[player]` when the player field is empty/out of range. Both must be bounds-guarded because `spawn()` accepts arbitrary `player` ints (`:2186`) and sim code calls it with constructed indices (e.g. selftest `selftest.gd:237,362` uses players 0/1). [OBS + DER]

### 3.2 The change

1. **Add one small read-only helper** in `game.gd`, placed next to `_nation_name()` (`:425-432`) or `train_unit()` (`:3973`), mirroring `train_unit()`'s nation lookup verbatim:

   ```
   func _spawn_sid(player: int, sid: String) -> String:
       var nat := ""
       if player >= 0 and player < players.size():
           nat = str(players[player].get("nation", ""))
       if nat == "" and player >= 0 and player < Data.PLAYER_NATIONS.size():
           nat = str(Data.PLAYER_NATIONS[player])
       return Data.resolve_sid(nat, sid)
   ```

   It adds no state, writes no entity field and does no file probing (sim layer must not duplicate `world3d_entities.gd:676-680`). [DER]

2. **Apply it only to the `BATTLE_ARMY` loop** in `_spawn_starts()` at `game.gd:2733-2740`: compute `var rsid := _spawn_sid(i, sid)` once per army entry and pass `rsid` to `spawn()` at `:2739`. Keep `total` (`:2733-2734`) and the ring/angle arithmetic (`:2738-2740`) computed from the **generic** army counts, so map layout, `next_id` ordering and RNG draws stay byte-stable. [DER]

3. **Leave `cen` `:2710`, `peasant` `:2721`, `tow` `:2725`, `cannon` `:2727`, `cmd_build`'s `spawn()` `:3939`, and the queue-completion `spawn(job.sid, ...)` `:5495` untouched.** Justification: none of those sids has a `NATION_UNITS` entry (`data.gd:294-305`), so resolving them is a no-op today; `cen` is additionally depended on by town-hall logic (`:2935`), `peasant` by builder logic (`:3924,:3956`), and the direct `spawn()` calls by tests (§4). Keeping them literal is the smallest change with the smallest blast radius. [OBS + DER]

4. **Do not modify `spawn()` itself (`:2186-2197`)** and **do not add `e["nation"]`**. `world3d_entities.gd:653-671` already recovers nation from player state, so an entity field is redundant; adding one would change the `serialize()` shape (`game.gd:5732-5767`) and invalidate the selftest baseline-parity print (`selftest.gd:82-96`), i.e. weaken a gate. [OBS + DER]

5. **Do not modify `train_unit()` (`:3973-3979`).** It already resolves; its queue carries the resolved sid (`:4039,:4048`) and completion reuses it (`:5495`). Re-resolving would be idempotent for `rus` (`resolve_sid("rus","strelet") == "strelet"`, noted in `NATION_DONOR_01.md` G3 `:183`) but is unnecessary churn. [OBS + DER]

### 3.3 Resolve-when-art-exists and fallback (two stages, do not merge)

- **Data stage (this ticket):** `Data.resolve_sid` (`data.gd:1564-1567`) yields a nation-specific sid only if `NATION_UNITS[nat]` maps the generic sid *and* the mapped sid is in `UNITS`. That is the "art exists" test available to the sim. For `rus` at default, `serdiuk→strelet`, `cossack→cossackdon`, `priest→pope` are real (`data.gd:823,1059,1010`; `manifest.json:2361-2367,2741-2747,2836-2842` show matching OBJ/texture). [OBS]
- **Art stage (already owned by NATION-MODEL-01):** `_entity_mesh_sid()` probes the actual mesh stem on disk (`world3d_entities.gd:676-680,730-735`) and falls back to the base sid with `NATION_MESH_FALLBACK_STATUS`; `_mesh_info()` falls back to a donor-bbox proxy if no OBJ/GLB exists (`:1072,1090-1091`). No crash, no new asset, no visual-parity assertion. [OBS]
- **Fallback that preserves current behavior:** `bav` has **no** `NATION_UNITS` key (`data.gd:294-305`), so `_spawn_sid(1, sid)` is the identity for every `BATTLE_ARMY` sid; identical for unmapped generics (`pikeman`, `archer`, `officer`, `cannon`) and for all nations absent from `NATION_UNITS`. Therefore the pre-change Bavarian starting-army sid histogram is preserved **exactly**, and the change is a strict no-op until `NATION_DATA_01` adds mappings (that report is not landed — [UNVERIFIED]). [DER] from `data.gd:1564-1567,294-305`; [OBS] on the missing `bav` key.
- **Interaction with the captured-nation override:** trained units already prefer `captured_nations` (`game.gd:3982-3987`). Starting-army resolution uses only the owning player's nation; captured nations cannot affect initial spawns because `_spawn_starts()` runs before capture. [DER] (ordering `:414-419`); relates to `NATION_FLOW_01.md:183-185` as [INF], not asserted here.
- **Known out-of-scope gaps (do not fix in this ticket):** `pikemanrus`/`officerrus`/`pearus` and `musketeer18bav`/`grenadierbav` are absent from both `UNITS` and the 172-model manifest (`NATION_DONOR_01.md` G8/G9 `:188-189`); `pikeman`, `officer`, `peasant` therefore remain generic sids even for `rus` after this change. Adding those units/meshes is a data/asset owner's job, not a spawn-wiring job. [OBS]

### 3.4 Mirror file

`app/scripts/game.gd` contains the same logic at **different offsets** (`spawn` `:1988`, `_spawn_starts` `:2504`, `train_unit` `:3775`, `resolve_sid` call `:3781`, nation assignment `:386`) [OBS]. `NATION_FLOW_01.md` and the task citation use the `variant3d` offsets, so this plan is written against `variant3d`. Whether `app/scripts/game.gd` is shipped in parallel and must receive the same edit is **[UNVERIFIED]** — do not assume parity of the two trees; confirm with the owning session before any implementation. [INF]

## 4. Discriminating probe and gates

### 4.1 Probe (read-only; not executed by this pass)

Start a skirmish with `nation0="rus"`, `nation1="bav"` and `START_OPTION` set so `army_mult > 0` or `battle_mode` is true (`game.gd:2707,2729`) — otherwise the `BATTLE_ARMY` branch does not run and no starting-army sid can be observed. Train one generic unit (e.g. `serdiuk` or `musketeer`) from a finished barracks for each player. Then dump, for each player `i ∈ {0,1}`:

```
{ player: i,
  cfg_nation:     cfg.players[i].nation,                     # main.gd:257-285 / menu.gd:958
  data_nation:    Data.PLAYER_NATIONS[i],                    # main.gd:410
  sim_nation:     game.players[i].get("nation"),             # game.gd:386
  start_sids:     histogram(e.sid for e in game.entities
                            if e.player == i and battle-army spawn),  # game.gd:2739
  trained_sid:    e.sid of one freshly trained unit,          # game.gd:3979 / :5495
  mesh_usage:     world3d_entities.stats["nation_mesh_usage"] rows for i,  # :742-747
  mesh_source:    world3d_entities.stats["mesh_sources_loaded"] + info["source"]  # :1093-1098
}
```

Collection means that already exist, all read-only: `--dump-config` prints `cfg.dump()` (`main.gd:197-199`); `game.serialize()` carries both `players[].nation` and `entities[].sid` (`game.gd:5732-5767`) and is written by `--dump-self-base` (`main.gd:814-843`) or the save path `user://lastgame.json` (`main.gd:1418`); renderer stats are exposed on `world3d_entities.stats` (`:466,:742-747,:1097-1098`). Note `testbridge.gd:_state()` (`:223-250`) reports only unit/building **counts** and has no sids, so it is **not sufficient** for this probe [OBS]. Whether an existing runner can read `world3d_entities.stats` without a new hook is **[UNVERIFIED]**; this ticket specifies no runner job. [OBS]

### 4.2 Interpretation (what discriminates)

- If `cfg_nation/data_nation/sim_nation` are `rus`/`bav` while `start_sids` for `rus` still contains `serdiuk`/`cossack` and `bav` equals its pre-change histogram, the only remaining sim-side drop is hop 5 — matched by this plan. [DER]
- If `rus` `start_sids` now contains `strelet`/`cossackdon` **and** `bav` is byte-identical to baseline, the plan behaved exactly as specified: nation-aware when data exists, identity fallback when it does not. [DER]
- If trained `rus` sid changes, or `bav` start/trained sids change, the fallback or the resolver was broken — fail. [DER]
- If a mesh-usage row shows a nation candidate selected without an on-disk stem, that is a renderer bug in another owner's file; do not patch it here. [DER]

### 4.3 Gate criteria — do not weaken `selftest` / `uitest`

| Gate | Criterion | Evidence | Label |
|---|---|---|---|
| S1 | All 29 `selftest.gd` STEPS (`:10-14`) still pass at the same count; **no assertion, step name or passed-condition edited** | `selftest.gd:10-14,98-115`; direct generic-sid spawns at `:237,361-362,380,392,445-446,493,497,514-515,524-525,545,579,675` rely on literal `pikeman`/`serdiuk`/`cannon` | [OBS + DER] |
| S2 | Baseline restore parity print stays `OK` — entity/serialize shape unchanged (no `nation` field added) | `selftest.gd:46-96`, esp. `:82-96`; `game.gd:5732-5767` | [OBS + DER] |
| U1 | All `uitest.gd` steps still pass, notably `menu_shell` with `nation0="tur", nation1="rus"` | `uitest.gd:104-113` | [OBS] |
| U2 | `u.sid == "pikeman"` selection path unchanged and `train_unit(0, bar, "pikeman")` unchanged | `uitest.gd:128-137,190` | [OBS + DER] |
| D1 | Fallback preserved: `bav` starting-army sid histogram and trained sid(s) byte-identical to a pre-change dump | `data.gd:294-305,1564-1567`; probe §4.1 | [DER] + [UNVERIFIED] until run |
| D2 | `rus` starting army resolves only mapped sids; unmapped generics (`pikeman`, `archer`, `officer`, `cannon`) stay generic | `data.gd:294-305,1561`; `game.gd:2733-2740` | [DER] + [UNVERIFIED] until run |
| D3 | No double-resolution: trained `rus` `strelet` remains `strelet`; queue sid path `:4039/:4048/:5495` untouched | `game.gd:3979,4039,4048,5495`; `NATION_DONOR_01.md:183` | [OBS + DER] |
| N1 | Negative gate: no edit to `spawn()` signature/entity dict, no edit to test drivers, no lowered step counts, no new nation field on entities | §3.1-3.4 | [DER] |

Running the gates is the implementing agent's job; this planning pass ran no Godot process and produced no report artifact other than this file. [OBS]

## 5. Open questions

1. `NATION_DATA_01.md` is not landed; the exact `rus`/`bav` `NATION_UNITS` entries it may add are **[UNVERIFIED]**. This plan deliberately does not guess them — its fallback is identity, so it is compatible with any later data addition (`data.gd:294-305`). [OBS on absence + DER]
2. Is `app/scripts/game.gd` a shipped mirror requiring an identical edit at its own offsets (`:1988,:2504,:3775`)? **[UNVERIFIED]**; do not infer parity from `variant3d`. [INF]
3. `NATION_DONOR_01.md` G8/G9 (`:188-189`) shows most nation-unique units have no port mesh/texture; whether "nation-aware spawn sid" is desirable for `rus` when the resolved mesh is a bbox proxy or a different donor family is a design call, not a code fact. **[UNVERIFIED]** — no visual claim made. [INF]
4. Can `world3d_entities.stats` be read by the existing headless runner without adding a hook? `testbridge.gd:223-250` lacks sid/stats fields; the `--dump-*` and save paths cover the sim half only. **[UNVERIFIED]**.
5. `NATION_FLOW_01.md`'s `world3d_entities.gd` line citations are stale after NATION-MODEL-01; this report re-cites current lines (§2 hops 8-9). Whether other reports still quote stale numbers is out of scope. [OBS]
6. Whether captured-nation override should ever influence starting spawns (it cannot, by ordering `:414-419` vs `:3982-3987`) — product question, **[UNVERIFIED]**. [DER on ordering, INF on desirability]

## 6. Summary

The nation value is intact through config → `Data.PLAYER_NATIONS` → `game.players[].nation` (`game.gd:386`) and the renderer already recovers it read-only (`world3d_entities.gd:653-671,695-739`). The **only sim-side gap** is `game.gd:2733-2740`, where `BATTLE_ARMY` starting sids are spawned literally without `Data.resolve_sid()`, unlike trained units at `game.gd:3976-3979`. [OBS + DER]

The minimal fix is one helper in `game.gd` that reuses `train_unit()`'s two-source nation lookup and calls `Data.resolve_sid()`, applied **only** to the army-spawn call at `game.gd:2739`; leave `spawn()` (`:2186`), the other literal starting spawns (`:2710,:2721,:2725,:2727`), `cmd_build` (`:3939`), queue handling (`:5495`) and both test drivers untouched. [DER]

Fallback is inherent: `data.gd:1564-1567` returns the original sid when no `NATION_UNITS` mapping exists or the mapped sid is missing from `UNITS`; `bav` has no mapping (`data.gd:294-305`), so Bavaria is a strict no-op, and the downstream mesh layer already falls back safely (`world3d_entities.gd:676-680,1072,1090-1091`). [OBS + DER]

The probe is a four-field-per-player sid/nation dump (§4.1) using existing `main.gd`/`serialize()` hooks; gates S1/S2/U1/U2/N1 forbid weakening selftest/uitest, and D1-D3 require a `rus`-only resolution with byte-identical `bav` behavior. [DER] Gates have **not** been run here. [OBS]

No donor/visual **parity claim** is made; art availability is cited only as on-disk mesh presence, and all unrun or unlanded items are labelled **[UNVERIFIED]**. [OBS]

*End of NATION-SPAWN-01.*
