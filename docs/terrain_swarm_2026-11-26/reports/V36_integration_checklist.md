---
id: V36
ticket: "TERRAIN-SWARM-2026-11-26 / V36 — definitive integration checklist for COORD (I01–I13)"
agent: "V36 (read-only integration-audit subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V36_integration_checklist.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V36_integration_checklist.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, gate, runner job or capture was used by V36. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing below is a PASS, a gate result or a parity claim."
scope_guard: "Read-only: file reads, git read commands, PowerShell Get-FileHash/Get-Content/ConvertFrom-Json/Test-Path/Get-ChildItem/Get-Item/Select-String and one read-only Python regex simulation were used. No .bak, source, shader, asset, test, manifest, config, queue, app/ byte or git state was changed."
multiple_passes: true
snapshot: "2026-11-26 09:52:04 +01:00 (08:52:04 UTC). Implementation files were still landing DURING this audit; hashes and line numbers below are snapshot values and MUST be re-read immediately before COORD acts (V11 §6 rule 4; V28 R7)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V36 — definitive integration checklist (I01–I13)

## 0. Multiple-pass log (owner directive, CHARTER.md:85-93)

No contradiction was accepted from one reading. Every anomaly below was re-read with a
second (often third) instrument; withdrawn items are recorded, not silently skipped.

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | `glob` for the task's four file families | Reported I03/I04/I07/I09/I10/I12 **ABSENT** | **Withdrawn** — glob returned stale/partial results |
| P2 | `git status --short -- variant3d/` (second command) | Showed `t_terrain_donor.gd`, `decode_pattern_lib.py`, `terrain_donor_gen.gd` present | Contradiction with P1 confirmed |
| P3 | PowerShell `Get-ChildItem` + per-path `Test-Path` sweep over 22 paths | Authoritative presence map; files still appearing between P3 and P6 | All per-ticket statuses below come from `Test-Path`, never glob |
| P4 | `grep` on `main.gd`/`world3d.gd` for seam symbols (read 1) | Seam **absent** in the V11 document; **present** in the live tree (`main.gd:125,189-191,593-594,1112-1113`, `world3d.gd:118,144-145,220-224,624,645,706-707`) | Seam status upgraded to LANDED; V11's "unapplied" is historical |
| P5 | `git diff --unified=0` on the two seam files (read 2) | 9 insertions in `main.gd`; 21 insertions + 1 deletion in `world3d.gd`; exactly one ternary replacement | Single-apply confirmed; no second worker edit of the seam |
| P6 | `Test-Path` sweep re-run at 09:52 | `terrain_donor_props.gd`, `terrain_donor_world.gd`, `decode_donor_masks.py` had landed since P3 | Statuses re-promoted to PRESENT; snapshot time pinned |
| P7 | `Test-Path` for `V28_code_review_r1.md` | First sweep ABSENT; second sweep PRESENT (worker landed it mid-audit) | V28 read in full and cross-referenced |
| P8 | Re-read of `terrain_donor_mesh.gd:196-213` (3rd read) | `_first()`/`_source_dicts()` accept **Dictionary** sources only; Object sources are skipped | I06-Object→I08 ingest defect confirmed, not a first-read artefact |
| P9 | Re-read of `terrain_donor_gen.gd:408` and `t_terrain_donor.gd:330-346` after both files changed hash | `generate(data: C3TerrainData, p: Dictionary = {})` vs test hook call `(SEED, GEN_KEYS, size, size)` still unchanged | I07↔I12 arity/type defect confirmed after repair window |
| P10 | Read-only Python regex replay of the I12 source-level guards over I06/I07/I08 | `visual_parity_claim` literal found in I08 comment (:13) → that check passes; active token `face_promotion` found in I08:660 `relief_mask_cells_no_face_promotion` | `no_synthetic_noise_field` check predicted HARD FAIL [D] |
| P11 | `Select-String` on `config.gd`/`config.json` for `backend` | No `features.terrain.backend` key in either; `cfg.text()` therefore yields its literal default `"legacy"` | Opt-in hook missing unless config file edited or setter called directly |

**[O] No anomaly was silently skipped.** All remaining unknowns are in §9.

---

## 1. Executive summary

1. **[O] Seam LANDED, not pending.** `main.gd` and `world3d.gd` are modified at `e234ac9b`; all four authoritative seam sites are present (§3 I11). Default is `"legacy"` at `main.gd:125`, `main.gd:189-191` and `world3d.gd:144`. Setter is called **before** `world.bind(game)` at both `main.gd:593-595` and `main.gd:1112-1114`, so `_terrain_locked` (`world3d.gd:645`) does not reject it. This is a single-apply seam (P5); do **not** re-apply it.
2. **[O] Backups are correct.** `inbox/backup/main.gd.bak-COORD-I11` = `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` and `inbox/backup/world3d.gd.bak-COORD-I11` = `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` — both **exactly** the V11 §2 pre-edit baselines. `tests_manifest.json.bak-I12` and `config.gd.bak-COORD-STAGE4` are ABSENT, consistent with `manifest.json` still at 40 tests and `config.gd` untouched.
3. **[O] 11 of 13 tickets have their canonical file present.** I01–I10, I11 (seam + composer) and I13 (QA harness + spec) are on disk. ABSENT (worker still running): I10's **canonical** shader path, N6 `build_terrain_new_manifest.py`, N7 `validate_terrain_new.py`, N10 `terrain_donor_tiles.gd`. I12's test file is present but its manifest registration is not.
4. **[D] The chain is NOT composable as landed — four hard API breaks.** (a) composer→I07 passes a game Object where `p: Dictionary` is required (`terrain_donor_world.gd:216` vs `terrain_donor_gen.gd:408`); (b) composer→I09 calls `bind()` which I09 does not define (`:229` vs `terrain_donor_props.gd:198` `build(...)`), so props are never built; (c) composer→I08 passes the I06 Object, but I08's ingest only reads Dictionaries (`terrain_donor_mesh.gd:196-213`), so `build()` returns false; (d) I12 calls `generate(SEED, GEN_KEYS, …)` against a typed `C3TerrainData` first parameter (`t_terrain_donor.gd:343-345`). Any of these alone yields an inert or failing donor backend.
5. **[D] Canonical-path conflict is real.** I10 landed at `variant3d/shaders/terrain_donor.gdshader`; V11 N13 (`V11_ownership_ledger.md:105`) and PLAN `:18` require `terrain_donor_shader.gdshader`. I08 `:67` and I12 `:43` reference the canonical name; only the composer (`:35-36`) tries both. Result: shader can load through the alias, but I08 telemetry still reports the legacy fallback and I12's optional-presence advisory reports `false`.
6. **[D] No gate was run and no capture exists.** `variant3d/assets/terrain_new/**` is entirely ungenerated; `inbox/qa/terrain_qa_report.json` and `inbox/qa/captures/` are ABSENT; `terrain_qa_spec.json` is `SCHEMA_ONLY__UNPOPULATED` with `signed:false`. `app/` is byte-identical (`git diff --exit-code -- app/` exit 0).
7. **[U]/PORT APPROXIMATION** Files were still being written during the audit (I06/I07/I08/I09/test/tools changed hash between passes). **No donor parity claim**; parity remains UNVERIFIED.

---

## 2. Evidence table (snapshot 09:52:04 +01:00)

Hashes are SHA-256 of working-tree bytes (PowerShell `Get-FileHash`); where only 24 hex are shown they are the leading 24 of the full digest. Git blob ids differ under `core.autocrlf=true` (V04 §0 P6).

| ID | Source (file:line / command) | Observation [O] unless labelled | Consequence [D] |
|---|---|---|---|
| EV01 | `git rev-parse --short HEAD`; `git log -1` | `e234ac9b`, `e234ac9bf2acb797e3b4a8b8bc1900208faf10a4`, Thu Nov 26 08:56:33 2026 +0100 | V11/V28 baseline is current; all line cites are `e234ac9b`-relative |
| EV02 | `git status --short -- variant3d/` | ` M main.gd`, ` M world3d.gd`, plus untracked donor files (§3) | Seam edits are uncommitted; rollback must be file-scoped |
| EV03 | `git status --short -- app/`; `git diff --exit-code -- app/` | empty, exit 0 | `app/**` byte-identical at snapshot; re-check before every gate |
| EV04 | `main.gd:125,189-191,593-594,1112-1113` | backend var, config read with coercion, two `set_terrain_backend()` calls | Authoritative `main.gd` seam present once each |
| EV05 | `world3d.gd:118,144-145,220-224,624,645,706-707` | const, var/`_terrain_locked`, setter, ternary, lock, 2 stats keys | Authoritative `world3d.gd` seam present once each |
| EV06 | `Get-FileHash main.gd` / `world3d.gd` | `FA9D93ED7C278F78…` / `EEC6560A1BC751B5…` (post-seam; world3d drifted mid-audit from `2848AE44…` with identical diff content) | Re-read before acting; drift likely LF/CRLF or late worker save [U] |
| EV07 | `Get-FileHash` on the two `.bak-COORD-I11` files | exactly `3859B605…` / `44EE96C0…` (full values §1.2) | Rollback baselines verified, not fabricated |
| EV08 | `Test-Path` for `tests_manifest.json.bak-I12`, `config.gd.bak-COORD-STAGE4` | both False; manifest `(ConvertFrom-Json).tests.Count` = 40, last `t_select_rect` | I12 EDIT step and stage-4 config flip not done |
| EV09 | `Test-Path` 22-path sweep + `git status` | 13 canonical implementation files + N17 present; N6/N7/N10/N13 absent | ABSENT = worker still running, not a defect (V28 §5) |
| EV10 | `terrain_donor_world.gd:216,218,224,229,231` | `generate(_data, game)`; `bind(game,_data)`; props `bind()` then `build()` | Three call-site/callee mismatches (§4) |
| EV11 | `terrain_donor_gen.gd:408` | `func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary` | Second arg Object ⇒ type error; returns telemetry, not a container/dump |
| EV12 | `t_terrain_donor.gd:343-345,637-661` | hook call `(SEED, GEN_KEYS, size, size)`; `REQUIRED_MODULES` now all present | Test generation hook cannot drive I07; guard passes, determinism fails |
| EV13 | `terrain_donor_mesh.gd:196-213,260-303` | `_source_dicts()` + `_first()` skip non-Dictionary sources; `_ingest()` reads only them | Passing I06 Object directly to `bind(g, d)` yields `w=0` and `build()=false` |
| EV14 | `terrain_donor_world.gd:35-36,151-175`; `terrain_donor.gdshader` present, canonical absent | alias fallback loads shader; I08 `:67` and I12 `:43` use canonical only | Split-view of shader availability; I08 telemetry mislabels fallback |
| EV15 | `Select-String config.gd`/`config.json` for `backend` | no key; `cfg.text("features.terrain.backend","legacy")` returns literal default | No config-driven opt-in without a config edit or direct setter |
| EV16 | read-only Python token replay of `t_terrain_donor.gd:91-92` over I08 | active line `terrain_donor_mesh.gd:660` contains `face_promotion` substring | `no_synthetic_noise_field` predicted hard FAIL [D], despite V28 noting the token is a positive guard |
| EV17 | `Test-Path` for all eight `assets/terrain_new/**` ledger outputs | all False; `variant3d/assets/terrain_new` does not exist | Decoders/atlas ran dry or not at all; I08 uses labelled legacy atlas fallback (`:377-383`) |
| EV18 | `terrain_qa_spec.json:1-25` | `SCHEMA_ONLY__UNPOPULATED__NO_PARITY_CLAIM`, all bands `value:null`, `signed:false`, `parity.status=UNVERIFIED` | `--policy red` must be refused; advisory only |
| EV19 | `terrain_qa_harness.py:163-196` | explicit rollback triggers, 5-step file-scoped restore, forbidden blanket restores | Copy these verbatim into COORD runbook (§7) |
| EV20 | `V28_code_review_r1.md:151-168` | F-01 owner collision, F-02 `DONOR_UNITS=160`, F-03 permanent-red `--check`, F-04–F-06 tautologies | Independent corroboration; none of these were "fixed" by V36 |

---

## 3. Per-ticket status (I01–I13)

`PRESENT` = exact canonical path exists at snapshot; `ABSENT (worker running)` = path returned False;
`PRESENT / NON-CANONICAL` = file exists but not at the V11/PLAN path. No absence is a failure claim.

| Ticket | Status | Exact path (V11 ledger row) | SHA-256 (24 hex) | Conflict / note |
|---|---|---|---|---|
| I01 | **FILE PRESENT** | `variant3d/tools/decode_donor_cfg.py` (N1) | `94EDEDECB1C5EAADEC7B8905…` | V28 F-03: `--check` permanently red (C01 20-vs-19); dry-run default ✓ |
| I02 | **FILE PRESENT** | `variant3d/tools/decode_donor_pattern.py` (N2) | `3790D3F34076B102B1E219F4…` | Owns G3/G4 but I03 emits them (V28 F-01) |
| I03 | **FILE PRESENT** | `variant3d/tools/decode_pattern_lib.py` (N3) | `F8EAF9B62F4987442CA9815A…` | Emits I02-owned `family_index.json` / `families/*.json` (V28 F-01) |
| I04 | **FILE PRESENT** | `variant3d/tools/decode_donor_masks.py` (N4) | `22753AE75E187E8E4D2297C6…` | Landed mid-audit; numpy dependency (V28 F-13) |
| I05 | **FILE PRESENT** | `variant3d/tools/build_terrain_new_atlas.py` (N5) | `982E212EB6085125F26F50C1…` | N6 `build_terrain_new_manifest.py` **ABSENT (worker running)**; Pillow dep |
| I06 | **FILE PRESENT** | `variant3d/scripts/terrain_donor_data.gd` (N8) | `77D7BFA1CF59578CCBE953B2…` | `class_name C3TerrainData`; changed hash twice mid-audit |
| I07 | **FILE PRESENT** | `variant3d/scripts/terrain_donor_gen.gd` (N9) | `3DA99FBA8AF2249BBCA71D1F…` | N10 `terrain_donor_tiles.gd` **ABSENT (worker running)**; typed API breaks two callers |
| I08 | **FILE PRESENT** | `variant3d/scripts/terrain_donor_mesh.gd` (N11) | `6AB8453AC9791B13099D814F…` | Shader path mismatch; Object-ingest mismatch; `face_promotion` token (V28 F-09/F-10/F-11) |
| I09 | **FILE PRESENT** | `variant3d/scripts/terrain_donor_props.gd` (N12) | `E86389151F54EEB9543B8DE2…` | No `bind()` method; `DONOR_UNITS=160` vs V08 (V28 F-02) |
| I10 | **PRESENT / NON-CANONICAL** | actual `variant3d/shaders/terrain_donor.gdshader` (A06 N7 alias) | `BB31B1EB03829B232040EB3D…` | canonical `variant3d/shaders/terrain_donor_shader.gdshader` (N13; PLAN `:18` says `variant3d/scripts/…`) **ABSENT (worker running)** — see C1 |
| I11 | **FILE PRESENT (EDIT LANDED)** | `variant3d/scripts/main.gd`, `variant3d/scripts/world3d.gd`; composer `variant3d/scripts/terrain_donor_world.gd` (N14) | main `FA9D93ED7C278F78…`; world `EEC6560A1BC751B5…`; composer `0B3672D4719F7816…` | seam single-applied; backups SHA-exact; composer degrades gracefully but is inert as wired |
| I12 | **FILE PRESENT / REGISTRATION ABSENT** | test `variant3d/tests/t_terrain_donor.gd` (N15) present; `variant3d/tests/manifest.json` **not edited**; `.bak-I12` **ABSENT** | test `13F079A64C17540AF8B16917…`; manifest `408F4C83…` | count 40 (needs 41, last `t_terrain_donor`); hook incompatible with I07; `face_promotion` guard FAIL risk |
| I13 | **FILE PRESENT / GATES NOT RUN** | `variant3d/tools/terrain_qa_harness.py` (N16), `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` (N17) | harness `74AC87EB8B928D90B2F1F962…`; spec `4D1BFE226FB80B796E09EB52…` | N7 `validate_terrain_new.py` **ABSENT (worker running)**; N18 report / N19 captures ABSENT; no gate result exists |

**Freeze-set check [O]:** `game.gd`, `world3d_terrain.gd`, `world3d_relief.gd`, `terrain_tileindex.gdshader`, `water3d.gd`, `project.godot`, `assets/terrain/**` show no new edits in `git status`; `app/` diff exit 0.

---

## 4. API compatibility matrix

Verdicts are static `[O]`/[D] from cited lines; **no Godot parse or run was performed by V36** `[U]`.

| # | Caller → callee | Caller site | Callee contract | Verdict | Effect if ignored |
|---|---|---|---|---|---|
| A1 | main.gd → world3d.set_terrain_backend | `main.gd:593-594,1112-1113` (before bind) | `world3d.gd:220-224`, lock only at `:645` | **OK** | none |
| A2 | world3d ternary → composer | `world3d.gd:624` | `terrain_donor_world.gd:1` extends Node3D, `bind`/`build`/`height_at_world` present | **OK** (file present) | opt-in no longer loads a missing script |
| A3 | composer → I06 data | `terrain_donor_world.gd:191,206` `from_live_object(game)` | `terrain_donor_data.gd:411` same signature (Object) | **OK** | read-only SoA view built |
| A4 | composer → I07 gen | `:216` `_call_adapt(_gen,"generate",[_data,game])` | `terrain_donor_gen.gd:408` `generate(data: C3TerrainData, p: Dictionary = {})`; `run` does not exist (`:212` fallback) | **BREAK** — game is Object, not Dictionary | `_gen_applied=false`; no donor generation at all |
| A5 | composer → I08 mesh | `:224` `callv("bind",[game,_data])` | `terrain_donor_mesh.gd:122` accepts both, but `:196-213` ingest reads **Dictionaries only**; `game` is an Object and I06 has no `fields` | **BREAK** — `_ingest()` returns false | `build()=false`; no mesh/water; composer reports `mesh_built=false` |
| A6 | composer → I09 props | `:229` `_call_adapt(_props,"bind",[game,_data,_mesh])`; `:231` `build([])` | `terrain_donor_props.gd:198` `build(p_container, p_stamps, p_options={})`; **no `bind`** | **BREAK** — `_props_applied=false` | `build()` never called; zero props |
| A7 | composer → I10 shader | `:35-36,151-175` canonical first, alias second | alias file present; canonical absent | **PARTIAL** — loads via alias; tries `set_donor_shader` (absent in I08), then swaps surface material | shader reaches the mesh surface, but I08 `stats.shader_path` still says legacy and I12 advisory says missing |
| A8 | I08 → I10 uniform names | `terrain_donor_mesh.gd:528-547` binds 15 params | `terrain_donor.gdshader:58-184` defines 9 of them (`tile_atlas`, `alpha_atlas`, `alphavert_atlas`, `atlas_grid`, `face_scale`, `donor_sun_position`, `ambient_rgb`, `diffuse_rgb`, `specular_rgb`); 6 are telemetry-only (`shadow_enabled`, `fog_mode`, `mask_to_alpha`, `alpha_from_mask`, `donor_blend_*`) | **PARTIAL / OK** — core samplers and light uniforms match; telemetry params unbound by design | no functional loss; shader also keeps donor defaults for `eye_plane_*`, `texture_matrix`, `uv_repeat`, `alpha_uv_scale`, `shininess`, water levels |
| A9 | I08 → collaborators | `terrain_donor_mesh.gd:430,573` | `tile_atlas_loader.gd`, `water3d.gd` signatures verified independently in V28 P6 | **OK** | none |
| A10 | I07 → I06 container | `terrain_donor_gen.gd:314,340-393` | `C3TerrainData` `.w/.h/.props/.meta/.stats()` present | **OK** | stage pipeline can write SoA fields when called correctly |
| A11 | I12 → I07 generation hook | `t_terrain_donor.gd:343-345` `(SEED, GEN_KEYS, size, size)` | `generate(data: C3TerrainData, p: Dictionary)`; `_call_hook` truncates to 2 args ⇒ `(int, Dictionary)` | **BREAK** — int where container required | `generate_streams_*` fails ⇒ all determinism checks fail |
| A12 | I12 → I07 return shape | `t_terrain_donor.gd:349-367` expects container/dump with `height`, `w/h`, `props` | `terrain_donor_gen.gd:393` returns `stats()` telemetry dictionary only | **BREAK** (secondary) | even after A11 repair, streams stay empty |
| A13 | I12 source guards → modules | `t_terrain_donor.gd:699-709` parity regex | found in I08 comment `:13` | **OK** | parity guard passes (textual, not runtime) |
| A14 | I12 synthesis guard → I08 | `t_terrain_donor.gd:91-92,714-728` token `face_promotion` | `terrain_donor_mesh.gd:660` active key `relief_mask_cells_no_face_promotion` | **BREAK** — substring match | `no_synthetic_noise_field` hard FAIL [D]; rename key in I08 or tighten guard in I12 (COORD decision) |
| A15 | I12 required modules → disk | `t_terrain_donor.gd:36-45` world/data/gen/mesh/props | all five present at snapshot | **OK** | guard `module_present` passes; shader/tiles remain advisory |
| A16 | world3d relief → composer height | `world3d.gd:665-666` `relief.bind(game, terrain)` | composer `height_at_world(p)` `:246-249` delegates to I08 or nearest-cell fallback | **OK** (degraded if A5 breaks) | relief may sample fallback heights |
| A17 | main.gd config → backend opt-in | `main.gd:189` `cfg.text("features.terrain.backend","legacy")` | no key in `config.gd` FEATURES_DEFAULTS or `config.json` | **MISSING HOOK** | donor cannot be enabled by stock config; requires config edit or direct `set_terrain_backend("donor")` on a test double |
| A18 | I03 → I02 output ownership | `decode_pattern_lib.py:1046,1048-1049` | V11 G3/G4 owned by I02 (`V11_ownership_ledger.md:123-124`) | **BREAK** — two writers, same dir | nondeterministic clobber of `family_index.json` / `families/*.json` |
| A19 | I09 scale ↔ I07 cell space | `terrain_donor_props.gd:76,585` `DONOR_UNITS=160` | `terrain_donor_gen.gd:28-34` V08 `[O]` 1:1 cell distances | **BREAK** — V28 F-02 | prop footprints scaled by an invented constant; no donor citation |

---

## 5. Conflict list

| ID | Conflict | Evidence | Severity | Required resolution before A/B |
|---|---|---|---|---|
| C1 | Shader path: landed `terrain_donor.gdshader` vs canonical `terrain_donor_shader.gdshader` (V11 N13 `V11_ownership_ledger.md:105`; PLAN `:18` even says `scripts/`) | EV14 | **HIGH** | Pick ONE: rename file to canonical **and** update composer alias list, **or** amend V11 N13/I08:67/I12:43 to the alias. Do not leave dual names. |
| C2 | Composer calls I07 with Object as typed Dictionary (`world3d.gd`→composer→gen) | A4/EV10/EV11 | **HIGH** | Pass a Dictionary of generation settings (`{}` plus pinned keys), never `game`; or add an adapter method in I07. |
| C3 | Composer→I08 passes I06 Object; I08 ingest is Dictionary-only | A5/EV13 | **HIGH** | Composer passes `_data.to_live()` / `to_dump()` Dictionary, **or** I08 `_source_dicts()` learns Object properties. |
| C4 | Composer→I09 calls nonexistent `bind()` | A6 | **HIGH** | Call `build(_data, stamps, {})` with stamps from I06/I07; append result to stats. |
| C5 | I12 hook arity/type + return shape vs I07 | A11/A12 | **HIGH** | Add a proper two-arg adapter (`generate(container, keys)`) or teach the test to construct `C3TerrainData` and pass a settings Dictionary. |
| C6 | `face_promotion` substring trips I12 synthesis guard | A14/EV16 | **MEDIUM** | Rename I08 telemetry key to `relief_cells_no_face_mode_promotion` **or** make the guard word-boundary aware. No gate weakening. |
| C7 | I03 emits I02-owned outputs into the same directory | A18 / V28 F-01 | **HIGH** | One writer per emitted path (COORD Q1 of V28); add collision guard to both decoders. |
| C8 | I09 `DONOR_UNITS=160` vs V08 1:1 cell space | A19 / V28 F-02 | **HIGH** | Retire the constant or cite a donor path:line. |
| C9 | I01 `--check` permanently red | V28 F-03 | **HIGH for gate 2** | Split claim (20) from derived (19) check; do not lower/delete the assertion. |
| C10 | N6/N7/N10/N13 still absent | EV09 | **MEDIUM** | Wait for workers or retire the ledger rows explicitly; no silent substitutions. |
| C11 | Manifest registration / backup missing | EV08 | **MEDIUM** | I12 stage C' only, LAST, with `tests_manifest.json.bak-I12` taken immediately before. |
| C12 | Four tautological self-checks | V28 F-04/F-05/F-06 | **MEDIUM** | Repair before trusting any harness/validator PASS line. |
| C13 | Volatile tree: hashes/line numbers changed during audit | EV06/P6 | **MEDIUM** | Freeze the tree before gates; re-run §6 step 0. |
| C14 | `app/**` untouched but `config.gd` would need a stage-4 edit for config-driven opt-in | A17 | **MEDIUM** | Use a config-file override or direct setter for A/B; keep `config.gd` in its deferred owner lane. |

**Explicitly NOT a conflict [O]:** three distinct `class_name` values (`C3TerrainData`, `C3TerrainDonorGen`, `C3TerrainDonorProps`) were checked by V28 P7 — no duplicate. V28 F-12's "no class_name anywhere" is a stale composer comment only.

---

## 6. Integration order — exact sequence, go/no-go, rollback

**Do not flip the default backend.** `terrain_backend` stays `"legacy"` throughout until step 8, and parity remains UNVERIFIED.
Each step is gated: if any NO-GO condition holds, stop the sequence; do not "run until green" (V28 `FORBIDDEN_RESTORE`).

| Step | Action (COORD only) | GO condition | NO-GO condition | Rollback for this step |
|---|---|---|---|---|
| 0 | **Preflight / freeze the tree.** Re-run `git rev-parse --short HEAD`, `git status --short -- variant3d/ -- app/`, P4/P5 seam greps, `Get-FileHash` on E1–E4 + both `.bak-COORD-I11`, `Test-Path` on the 4 ABSENT ledger paths. | HEAD stable; `app/` empty; seam greps exactly one of each; backup SHAs = §1.2; no worker still writing (compare two hashes 60 s apart) | any file still changing; missing backup; second seam | none (read-only). If a worker is mid-write, wait — do not restore. |
| 1 | **Resolve C1–C9 and C12.** COORD adjudications for shader path, gen/props/mesh adapters, test hook, I02/I03 ownership, I09 scale, I01 `--check`, tautologies. | each conflict has a written decision + owner + file:line; re-run P3 snapshot | any HIGH conflict undecided | none (decisions only). If a worker edited meanwhile, re-run step 0. |
| 2 | **Parse-before-switch (V11 §6 rule 5).** Pin Python interpreter (numpy/Pillow), `py_compile` all six tools; one Godot parse job via `godot_runner.py run --id V36-PARSE-1` after N10/N13 land or are retired. | zero Python syntax errors; Godot parses all modules; `missing_modules` empty when composer instantiated | any parse error; N10/N13 absent without explicit retirement | remove only the newly added files that fail (§7 step 3); keep backups; never blanket restore. |
| 3 | **Stage A — decoders/assets.** Run each tool dry-run, then `--write` to the single root `variant3d/assets/terrain_new/**` *after* C7/C9 resolved; verify emitted paths, shas, labels; `--out` must be outside the donor root. | G1–G11 present with provenance; no I02/I03 write collision; deterministic second run | collision or permanent-red `--check` | delete only regenerated `assets/terrain_new/**` files (creation ledger); tools stay inert. |
| 4 | **Stage B — runtime compose.** Verify composer→I07 Dictionary arg, composer→I08 Dictionary handoff (`to_live()`), composer→I09 `build(container, stamps, {})`, single shader path. Re-run parse job. | A4/A5/A6 green; `t_terrain_donor` hook can produce non-empty streams | any of A4/A5/A6 still BREAK | delete the newly created runtime files (§7 step 3); restore seam only if a seam file was touched. |
| 5 | **Stage C′ — I12 registration LAST.** Take `inbox/backup/tests_manifest.json.bak-I12` first; append exactly one entry `{id:"t_terrain_donor"}`; verify count 40→41 and last id. | backup exists; count 41; last id correct | backup missing; count ≠ 41 | id-level removal only (§7 step 1). Never restore the whole manifest. |
| 6 | **Legacy-default gates (no donor opt-in).** selftest 29/29, uitest 17/17, `t_render_mode` PASS (`seam_missing=false`), `assert_clean` CLEAN, `app/` byte-identical, freeze-set diff exit 0. Fresh runner ids. | all green with fresh JSON | any red, stale JSON, unacked runner failure, blank capture | restore seam from `.bak-COORD-I11` + remove I12 entry (§7 steps 1–2); then re-run D-5 to green. |
| 7 | **Opt-in donor A/B (only now).** Supply the backend through a config override or a direct `set_terrain_backend("donor")` before `bind()` (A17); run `t_terrain_donor`, harness `--policy advisory` to `inbox/qa/terrain_qa_report.json`, fresh 240²/320² captures. | determinism byte-identical on five streams; `missing_modules` empty; `mesh_built=true`; gates still green; `visual_parity_claim=false` | any hard FAIL, missing module, inert mesh, `app/` drift, donor-parity claim | set backend back to `"legacy"` (remove override); if the switch was made by editing a seam/config file, restore that file from its named backup (§7 step 2). |
| 8 | **Owner sign-off / honest verdict.** Record three-tier verdict; parity stays UNVERIFIED unless a real matched-seed donor GPU frame exists (it does not at snapshot). Default flip to donor is a **separate ticket** (V11 §7 deferred stage 4). | report written with labels and evidence ids | any parity claim, signed `--policy red` without donor spec, lowered threshold | keep legacy default; no code rollback needed for a report. |

**Critical sequencing note [D]:** steps 4–7 are **meaningless** until C2/C3/C4/C5 are repaired. As landed, enabling `terrain_backend="donor"` instantiates the composer successfully but produces `_gen_applied=false`, `_props_applied=false`, `mesh_built=false` (`terrain_donor_world.gd:205-229`) — an inert backend that can silently "pass" a shallow smoke test. Require explicit stats assertions, not just absence of errors.

---

## 7. Rollback commands (file-scoped, reverse order; COORD/owner only)

Derived from V11 §7 / `terrain_qa_harness.py:177-196`. **Never** use `git reset --hard`, `git checkout .`, `git clean -fd`, blanket `Copy-Item`, or delete a `.bak`. Verify SHA-256 after each copy.

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"

# 0. Re-verify baselines before touching anything
Get-FileHash -Algorithm SHA256 -LiteralPath 'inbox\backup\main.gd.bak-COORD-I11','inbox\backup\world3d.gd.bak-COORD-I11','variant3d\scripts\main.gd','variant3d\scripts\world3d.gd','variant3d\tests\manifest.json' | Format-Table -AutoSize

# 1. Remove ONLY the I12 entry by id (never whole-file restore; backup must exist)
python -c "import json,pathlib; p=pathlib.Path('variant3d/tests/manifest.json'); d=json.loads(p.read_text(encoding='utf-8')); d['tests']=[t for t in d['tests'] if t.get('id')!='t_terrain_donor']; p.write_text(json.dumps(d,sort_keys=True,indent=2)+'\n',encoding='utf-8')"
# expected: count 41 -> 40; last id t_select_rect

# 2. Restore the two seam files from their verified backups (world first, then main)
Copy-Item -LiteralPath 'inbox\backup\world3d.gd.bak-COORD-I11' -Destination 'variant3d\scripts\world3d.gd'
Copy-Item -LiteralPath 'inbox\backup\main.gd.bak-COORD-I11'   -Destination 'variant3d\scripts\main.gd'
# expected: 44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A
#           3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8

# 3. Delete only creation-ledger files that actually landed (adjust to the final snapshot)
Remove-Item -LiteralPath 'variant3d\scripts\terrain_donor_world.gd'
Remove-Item -LiteralPath 'variant3d\scripts\terrain_donor_tiles.gd','variant3d\scripts\terrain_donor_gen.gd','variant3d\scripts\terrain_donor_mesh.gd','variant3d\scripts\terrain_donor_props.gd'
Remove-Item -LiteralPath 'variant3d\shaders\terrain_donor_shader.gdshader','variant3d\shaders\terrain_donor.gdshader' -ErrorAction SilentlyContinue
Remove-Item -LiteralPath 'variant3d\tests\t_terrain_donor.gd'

# 4. Keep inert tools/assets (regenerable); switch composition back to legacy by default.
#    Do NOT delete .bak files. Do NOT re-run gates until green; record the reason.

# 5. Final invariants
git diff --exit-code -- app/ variant3d/scripts/game.gd variant3d/scripts/world3d_terrain.gd variant3d/scripts/world3d_relief.gd variant3d/shaders/terrain_tileindex.gdshader variant3d/project.godot
Select-String -LiteralPath 'variant3d\scripts\world3d.gd' -Pattern 'terrain_backend|TERRAIN_DONOR_SCRIPT|set_terrain_backend'
# expected: no hits; exit 0; app/ empty
```

**Creation-ledger rollback** (derived assets, regenerable, no backup): remove only files under
`variant3d/assets/terrain_new/**` that the emitted root manifest lists; leave `variant3d/assets/terrain/**` untouched.

---

## 8. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | Opt-in donor backend silently inert (no mesh/props/gen) yet shallow smoke test green | **[D] HIGH** | A4/A5/A6 + composer `degrade gracefully` (`:15-19`); require `mesh_built`/`gen_applied`/`props_applied` assertions and `missing_modules` empty |
| R2 | Two shader names drift apart (I08/I12 canonical vs landed alias) | **[D] HIGH** | C1; one name, one owner, explicitly retired alias |
| R3 | I12 atom hard-fails on `face_promotion` substring or hook arity and is mistaken for a donor defect | **[D] MEDIUM** | A11/A14; repair guard/adapter, never delete the check |
| R4 | Two tools write `family_index.json` / `families/*.json` | **[D] HIGH** | C7 / V28 F-01; one writer per path + collision guard |
| R5 | I01 permanent-red `--check` is "fixed" by changing the donor 20 to 19 | **[D] MEDIUM** | C9; preserve contradiction, split claim vs derived check |
| R6 | Prop scale `DONOR_UNITS=160` silently changes all landscape footprints | **[D] HIGH** | C8 / V28 F-02; cite donor or remove |
| R7 | Volatile tree invalidates hashes and line cites before gates | **[U] MEDIUM** | EV06/P6; freeze + re-run step 0 |
| R8 | Wrong Python interpreter (numpy/Pillow) breaks tool gating | **[U] MEDIUM** | V28 F-13; pin interpreter in runbook |
| R9 | Tautological harness/validator self-checks create false confidence | **[D] MEDIUM** | V28 F-04/F-05/F-06; repair first |
| R10 | Visual "improvement" is reported as donor parity | **[U]/PORT APPROX HIGH** | EV18; parity stays UNVERIFIED, no donor GPU A/B frame |
| R11 | Full-body GDScript defects (I07 stages, I09 bodies, I12 hooks) not covered by this integration audit | **[U] MEDIUM** | V28 R1 scope; V28 R2 / Godot parse needed |
| R12 | Rolling back with a blanket git command destroys uncommitted docs work | **[D] MEDIUM** | §7 forbidden list; file-scoped `Copy-Item` only |

---

## 9. Open questions for COORD

1. **Q1.** C1: rename I10's shader to canonical `terrain_donor_shader.gdshader` and update `terrain_donor_world.gd:36`, `terrain_donor_mesh.gd:67`, `t_terrain_donor.gd:43` together — or amend the ledger to the landed alias? (PLAN `:18` adds a third spelling under `scripts/`.)
2. **Q2.** C2/C3/C4/C5: who is the single owner authorised to repair the four adapter call sites (composer, I08 ingest, I12 hook) without violating one-owner-per-file (V11 §6)? Currently these are four different owners' files.
3. **Q3.** Q1/Q2 of V28: who owns `family_index.json` / `families/*.json` after F-01, and is `DONOR_UNITS=160` retired per V08 for I09?
4. **Q4.** C6: rename I08's `relief_mask_cells_no_face_promotion` key, or make I12's token guard word-boundary aware? Both preserve the guard; neither lowers a gate.
5. **Q5.** A17: how will COORD opt in for A/B — config-file override, or direct `set_terrain_backend("donor")` on a test double? If `config.gd` is edited, it must be the deferred `COORD-STAGE4` owner with `.bak-COORD-STAGE4` (currently ABSENT).
6. **Q6.** Are N6/N7/N10/N13 going to land, or should COORD formally retire them from V11 §3 before step 2 (`parse-before-switch`)?
7. **Q7.** May this checklist be re-run against a frozen tree before step 6? Hashes changed three times during V36 (§0 P6/EV06); the snapshot is 09:52:04 +01:00 only.
8. **Q8.** Does COORD accept V28's F-03 split (20 claim / 19 derived) as the gate-2 remedy, given that no donor byte was run by any worker in this audit?

---

## 10. Handoff summary (5 lines)

1. **Verdict:** seam LANDED and single-applied (`main.gd:125,189-191,593-594,1112-1113`; `world3d.gd:118,144-145,220-224,624,645,706-707`), backups SHA-exact (`3859B605…`, `44EE96C0…`), `app/` clean at `e234ac9b`; do not re-apply the seam.
2. **Files:** I01–I10 + I11 (seam/composer) + I13 present; I12 test present but manifest still 40 tests; ABSENT (worker running): canonical I10 shader, N6, N7, N10, `.bak-I12`, stage-4 config backup and all `assets/terrain_new/**` outputs.
3. **Blocking defects:** composer→gen (Object vs Dictionary), composer→I08 (Dictionary-only ingest), composer→I09 (`bind` absent), I12→I07 hook arity/return-shape, plus I10 path conflict and V28 F-01/F-02/F-03 — the donor backend is inert as wired (§4/§5).
4. **Order:** freeze → adjudicate conflicts → parse → tools/assets → repair runtime adapters → manifest LAST → legacy-default gates → opt-in A/B → honest sign-off; no default flip, no parity claim.
5. **Guards:** 11 multi-pass readings recorded; no source, shader, asset, test, backup, git, runner, Godot, gate or donor state changed by V36; **no donor parity claim** — parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

*End of V36 report. Exactly one report written; no other file was created, edited or deleted.*
