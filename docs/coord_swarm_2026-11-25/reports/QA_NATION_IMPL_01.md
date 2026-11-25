---
id: QA-NATION-IMPL-01
task: "Verify nation data / spawn / mesh fixes after their owners land"
date: 2026-11-25
status: COMPLETE — READ-ONLY QA; NO CODE EDIT, NO RUNNER JOB
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/QA_NATION_IMPL_01.md"
scope: "Byte/hash diff of three owned scripts against their pre-edit backups; read of the landed planning + implementation reports and already-existing runner artifacts. No file outside this report was written. No Godot process, no queue mutation."
labels: observed | derived | inferred | UNVERIFIED
label_key: "observed = literal bytes/artifact read this pass | derived = control-flow/arithmetic over observed bytes | inferred = strong but indirect | UNVERIFIED = no direct evidence in this read set"
parity_claim: none
verdict: "CODE CONFIRMED 3/3; runtime evidence PARTIAL; exact-nation art BLOCKED / UNVERIFIED"
---

# QA-NATION-IMPL-01 — nation data/spawn/mesh verification

## 1. Sources

| Tag | Source | Read this pass | Label |
|---|---|---|---|
| **L1** | `variant3d/scripts/data.gd` — 88,123 B, SHA-256 `89B1519D…E919` | direct bytes | observed |
| **B1** | `inbox/backup/data.gd.bak-NATIONDATA01` — 88,067 B, SHA-256 `B7F5FBDE…EFD` | direct bytes | observed |
| **L2** | `variant3d/scripts/game.gd` — 236,991 B, SHA-256 `BB2265C7…884D` | direct bytes | observed |
| **B2** | `inbox/backup/game.gd.bak-NATIONSPAWN01` — 236,360 B, SHA-256 `D549C9CC…BF09` | direct bytes | observed |
| **L3** | `variant3d/scripts/world3d_entities.gd` — 103,539 B, SHA-256 `4C763ABF…8951` | direct bytes | observed |
| **B3** | `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01` — 93,632 B, SHA-256 `9C797DFB…199` (hash cited in `NATION_MODEL_01.md:11` matches) | direct bytes | observed |
| **P1** | `reports/NATION_DATA_01.md` (plan), `reports/NATION_DATA_IMPL_01.md` (landed, final result at `:112`) | direct read | observed |
| **P2** | `reports/NATION_SPAWN_01.md` (plan), `reports/NATION_SPAWN_IMPL_01.md` (landed, final result `:5,:123`) | direct read | observed |
| **P3** | `reports/NATION_MODEL_01.md` (landed, final results `:92-106`, open questions `:109-118`) | direct read | observed |
| **J** | `variant3d/.godot_queue/results/00000536_nationmodel01-probe2/stdout.txt`, `…/00000544_nationmodel01-probe3/stdout.txt`, `…/00000542_nationdata01-smoke/{stdout,stderr}.txt`, `…/00000533_nationspawn01-smoke/`, `…/00000538_nationspawn01-sid-dump/stderr.txt` | direct read of existing artifacts; **no job run by QA** | observed |
| **G** | `git diff --no-index` / `git log` / `git status` over the root, plus Python `difflib`/hash checks | direct command output | observed / derived |

**Method.** Each live script was compared only with its own named pre-edit backup. Diff counts below are `git diff --no-index --numstat` (authoritative) and are labelled derived where arithmetic is involved. Line numbers are 1-based, current live file unless marked "backup". Concurrent owners were still writing reports during this pass; all three implementation reports and their final result sections were present at the time of writing.

## 2. Verification table

| Fix | Expected change | Observed diff | Status | Label |
|---|---|---|---|---|
| **Bavaria map entry** (`data.gd`) | One inserted line in `NATION_UNITS`: `"bav": {"serdiuk": "musketeer", "cossack": "hussar"},` immediately after `rus` (`NATION_DATA_01.md:120-141`; impl `§1`) | `+1 / −0`; one hunk `@@ -293,6 +293,7 @@`; literal line present at **live `:296`**, `rus` at `:295` byte-identical, `NATION_UNITS` header at `:294`. No other hunk. | **CONFIRMED** | observed |
| **MORALE-02 preservation** (`data.gd`) | Banners/constants byte-identical by content, not line number (`NATION_DATA_01.md:158-164`) | Backup `:81-132` hash == live `:81-132`; backup `:588-602` hash == live **`:589-603`** (shifted by the insert, bytes equal). `PORT_MORALE_FAMINE_ENABLED` at live `:133`, marker counts unchanged. Removing the one added line reproduces the backup byte-for-byte. | **CONFIRMED** | observed / derived |
| **BATTLE_ARMY sid resolution** (`game.gd`) | One read-only `_spawn_sid()` helper + resolution applied **only** to the army spawn call; `spawn()`/entity dict/tests untouched (`NATION_SPAWN_01.md:57-87`) | `+13 / −1`, exactly two hunks: helper inserted at live **`:433-444`** (`func` at `:438`), and `spawn(sid, …)` → `spawn(_spawn_sid(i, sid), …)` at live **`:2751`**. `func spawn(` still `:2198`, `train_unit` `:3985`, `serialize` `:5744` — no shape change. `BATTLE_ARMY` keys at `data.gd:1562`; resolver at `:1565-1568`. | **CONFIRMED (code)** | observed |
| **Runtime BATTLE_ARMY sid histogram** | Resolved `rus` sids observable in `game.serialize()`; `bav` baseline preserved (`NATION_SPAWN_01.md:104-127`) | Parse smoke `533` ok/0 (stdout banner only). Sid-dump `538` **timed out** at 240 s; stderr only `[runner] KILLED …`, no dump file, no histogram. | **UNVERIFIED** (not a code defect) | observed |
| **Renderer nation probe** (`world3d_entities.gd`) | Nation recovered read-only, on-disk candidate probe, donor prefix rule, mesh-sid helper, usage telemetry (`NATION_MODEL_01.md:59-65`) | `+205 / −3`, hunks at backup `:88,:186,:446,:621,:1012,:1409,:1423,:1436` only. Live: `const Data` `:93`; `_nation_of` **`:655`**, `_nation_mesh_on_disk` **`:678`**, `_donor_building_prefix` **`:691`**, `_entity_mesh_sid` **`:736`**, `_record_nation_mesh` **`:779`**; `stats` keys at `:464-470`; batch/building meta tags at `:1606-1615` / `:1626-1635`. Only `ResourceLoader.exists()` probes; no file creation. | **CONFIRMED** | observed |
| **Build-order action** (`world3d_entities.gd`) | `build`/`repair` + measured speed `< WALK_SPEED_GATE_M_S` → `construct`, dead-first, other branches unchanged (`NATION_MODEL_01.md:64`; `BUILD_ANIM_01.md:107`) | Branch at live **`:1173-1195`** (dead check `:1174`, `otype == "build"/"repair"` `:1185`, gate `:1186-1190`), call site `:2031` passes `_measure_speed()` result. Existing probe artifacts: `536` and final `544` both report `build_still→construct`, `repair_still→construct`, `build_walking→walk`, `idle_still→idle`, `dead_builder→death`. | **CONFIRMED (structural + owner probe)** | observed |
| **Protected rotor / stage / tree / motion blocks** | No edit inside those blocks; declared exceptions are the `MORPH_ACTION_MAP` label and the `_unit_action` branch (`NATION_MODEL_01.md:66,111,125`) | All nine changed backup regions map to: constants header (`:88`), `MORPH_ACTION_MAP` + labels (`:186`), `bind()` stats (`:446`), insertion before `FIX-COLOR` (`:621`), `_unit_action` (`:1012`), `add_unit` (`:1409,:1423`), `add_building` (`:1436`). **No hunk** intersects rotor constants/blocks, `BUILD-STAGES-01` constants/selectors/sync, DECOR tree pool/ENV ladders, or the MOTION presentation constants/sync. | **CONFIRMED** | observed / derived |
| **No test weakening** | No assertion, step name, step count or passed-condition changed by nation owners (`NATION_SPAWN_01.md:129-140`; `NATION_DATA_01.md:181`) | `git diff 2411a752 HEAD` for `selftest.gd`, `uitest.gd`, `testbridge.gd` is empty; `git status` shows no nation-owner edit to any test file. The only recent selftest change (commit `2411a752`) **adds** placement attempts/diagnostics in `_spot()` and leaves the 29-step `STEPS` list and passed conditions intact. No lowered gate was observed. | **CONFIRMED** | observed / derived |
| **No invented art names** | Only donor-derived sids/prefixes probed on disk; misses labelled BLOCKED, never claimed as fixed (`NATION_MODEL_01.md:99,108-109`) | Code candidates come from `Data.resolve_sid()` and `_donor_building_prefix(nation, family) + base_sid` (e.g. `ruscen`, `eurmil`, `bavbar`), each checked with `ResourceLoader.exists()`; naval branch appends nothing. No `.obj`/manifest/asset write in any owner diff. Disk enumeration: **0** `rus*`/`bav*`/`eur*` building-prefix OBJs; only `sco_highlandersword.obj` matches a nation-coded unit stem. | **CONFIRMED (no invention); missing art BLOCKED** | observed |
| **Owner reports landed** | `NATION_DATA_IMPL_01.md`, `NATION_SPAWN_IMPL_01.md`, `NATION_MODEL_01.md` | All three present at write time, with final result sections filled (data `:112`, spawn `:5,:123`, model `:92-106`). All carry `parity_claim: none/false`. Note: `SWARM_BOARD.md:297,307,323,333` still says RUNNING for the owner sessions; board lag only, not a code fact. | **CONFIRMED** (documentation) | observed |
| **"Generic target is conservative fallback" claim** | `NATION_MODEL_01.md:114` says the removed value-list heuristic means a generic target is now labelled fallback | The heuristic removal is confirmed (probe `544`: `bav/musketeer→musketeer exact=false`). **But** for a *remapped* generic sid, live `_entity_mesh_sid` `:166-168` appends `rsid` whenever `rsid != base_sid` and sets `exact=true` on disk hit (`:176-182`). With `bav: serdiuk→musketeer` and `hussar` targets present, `bav/serdiuk` would be labelled `exact=true`. Probe artifacts did not exercise `bav/serdiuk`. | **PARTIAL** | derived (runtime UNVERIFIED) |
| **"`bav` strict no-op" claim** | `NATION_SPAWN_IMPL_01.md:5,114-126,169` says `bav` starting sids are unchanged | True at the time that code/report was written (`bav` had no `NATION_UNITS` key), but **stale after the data owner landed `:296`**. Now `_spawn_sid(1, "serdiuk") → "musketeer"` and `("cossack") → "hussar"`; both OBJs exist. Report `§5` is documentation lag, not a regression. | **PARTIAL** (documentation) | observed / derived |

## 3. Cross-fix interaction notes

1. **Order of landing matters.** Spawn resolution is data-driven: `game.gd:2751` calls `Data.resolve_sid()`; the later `data.gd:296` insert changes `bav` behaviour from identity to two concrete remaps. The spawn report's "strict no-op" assertion and the model report's "generic target = fallback" assertion are both snapshots from before/around the data insert. [observed + derived]
2. **Mesh exactness semantics.** For `rus` remaps (`musketeer→strelet`, `cossack→cossackdon`) `exact=true` is donor-grounded. For `bav` remaps the target sid exists on disk but is a generic donor-family mesh; `NATION_DATA_IMPL_01.md:127` and `NATION_MODEL_01.md:114` explicitly refuse a donor-faithful/visual claim. QA does **not** convert `exact=true` into a parity claim. [derived]
3. **Art gap is load-bearing and unresolved.** Nation-prefixed 3D meshes/textures are absent (0 building-prefix OBJs; manifest still generic/`ukr*` per owner reports). Missing `bav`/`rus` art is **BLOCKED / UNVERIFIED**, not "fixed", and not evidence for parity. [observed absence + inferred cause; no visual capture inspected]
4. **Concurrent unrelated edits.** At final read, `git status` also showed modified `variant3d/scripts/main.gd`, `variant3d/tests/t_load_usability.gd` and several docs by other sessions. None is among the three nation-owned scripts or the named test drivers; not attributed to these fixes. [observed]

## 4. Verdict

- **All three code fixes landed and match their own pre-edit backups byte-for-byte at the intended scope**: data `+1/−0`, spawn `+13/−1`, model `+205/−3` (the last figure matches the corrected `NATION_MODEL_01.md:51`; an earlier revision of that report cited `+197/−3`).
- **Confirmed:** Bavaria map entry; MORALE preservation; BATTLE_ARMY helper + single call-site wiring; renderer nation probe and telemetry; build-order `construct` branch with dead-first + speed gate; protection of rotor/stage/tree/motion blocks; no test weakening; no invented art names.
- **Partial / unverified:** runtime BATTLE_ARMY sid histogram (dump timed out); "no-op for bav" now stale; "generic target = fallback" holds for identity sids but not for the new `bav` remaps; visual/nation art parity is **UNVERIFIED / BLOCKED** and is claimed by nobody.
- **No runner job was launched and no code was edited by this QA.** Parse smokes and owner probes cited here are pre-existing artifacts, read only.

## 5. Open questions

1. Should `_entity_mesh_sid()` distinguish "nation remap to a generic sid" from "nation remap to a nation-coded sid", so `bav/serdiuk→musketeer` is not counted as `exact=true`? Runtime discriminator: `bav/serdiuk` and `bav/cossack` in a fresh probe. [derived; measurement UNVERIFIED]
2. Will a later gate obtain the per-player sid dump (`--battle --dump-self-base` with a longer timeout) and confirm resolved `rus`/`bav` starting-army sids? [UNVERIFIED]
3. Is `app/scripts/game.gd` (separate mirror at different offsets, `NATION_SPAWN_01.md:99`) in scope for the same spawn fix? It was not edited by the owner. [UNVERIFIED]
4. Will asset owners supply `rus*`/`bav*`/`eur*` 3D meshes + textures and donor-exact Bavarian units (`musketeer18bav`, `grenadierbav`)? Until then the reported Ukrainian look is **BLOCKED**, not fixed. [UNVERIFIED]
5. Does the V7-74 morph path still bypass the nation-resolved key when a registered skin exists (`NATION_MODEL_01.md:115`)? [UNVERIFIED]
6. Are `construct` pose frames exported? Probe shows the *action string* changes, but shipped skins may snap to death/attack0 (`NATION_MODEL_01.md:116`). [UNVERIFIED]
7. Can captured-nation sids reach the same mesh helper, and is that desirable (`NATION_MODEL_01.md:113`)? [UNVERIFIED]
8. Board rows remain RUNNING for all nation sessions at read time; owners may amend their reports after this QA snapshot. [observed]

## 6. Summary

- Bavaria's `NATION_UNITS` line is present exactly as planned; `rus` and both MORALE regions are byte-preserved. [observed]
- `BATTLE_ARMY` now routes through a read-only `_spawn_sid()` at one call site; runtime histogram remains unmeasured because the dump job timed out. [observed / UNVERIFIED]
- The renderer nation probe and the build→`construct` action are present, structurally correct, and corroborated by existing parse smokes and owner probe artifacts; no protected rotor/stage/tree/motion block was touched. [observed]
- Tests were not weakened; no nation-prefixed art name was fabricated. Missing nation art stays **BLOCKED / UNVERIFIED**; no donor or visual parity is asserted anywhere in this report. [observed / derived]
- Two owner claims are stale enough to flag: `bav` is no longer a strict no-op, and a remapped generic target can still be labelled `exact=true`. [derived]
