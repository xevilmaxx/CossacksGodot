---
id: V04
ticket: "TERRAIN-SWARM-2026-11-26 / V04 — exact current-state audit of port files a fresh terrain module must coexist with"
agent: "V04 (read-only tree-conflict / hash / rollback subagent)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V04_tree_conflicts.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V04_tree_conflicts.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor data, donor frame, Godot process, runner job, capture or gate was used. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing here is a PASS claim."
scope_guard: "Read-only. Only git status/diff/log/show/hash-object/ls-files/rev-parse, PowerShell Get-FileHash/Get-Content/Select-String/Test-Path and file reads were used. No .bak-V04 file was created; rollback commands below are for COORD only."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V04 — tree conflicts: exact current-state audit of the port files

## Executive summary

1. **[O] The single most important finding: the three "uncommitted" port edits that P06 §5.1 and A06 E12/E13 warn about NO LONGER EXIST as working-tree edits.** They were committed in `e234ac9b` (2026-11-26 08:56:33 +0100, `step`). At this audit `HEAD=e234ac9b` and `git status --short -- variant3d/` and `git status --short -- app/` are **empty** in every pass; `git diff --exit-code -- variant3d/` returns 0. The Y08b `game.gd` scoping fix, Y10 anisotropic shader token and Y11 `project.godot` level-4 key are **present in HEAD** (`game.gd:382,388,393-398,2151-2166`; `terrain_tileindex.gdshader:60`; `project.godot:28`). `[D]` Implementation workers must treat them as landed baseline, not as diffs to re-apply. V05 §0 pass 2/3 and §6 item 3 reached the same verdict independently; this report supplies the hash/backup detail V05 called `[U]`.
2. **[O] The only uncommitted changes are inside `docs/terrain_swarm_2026-11-26/`**: tracked modifications to `CHARTER.md`, `SWARM_BOARD.md`, `spec/11_ASSET_CONVERSION.md`, and numerous untracked reports/specs (list in §2 R4). No source, shader, config, asset, test or `app/` file is dirty. A blanket `git reset --hard` / `git checkout -- .` would still destroy COORD's in-flight doc work, so the file-scoped discipline remains valid even though its original stated reason (three dirty source files) is stale.
3. **[O] The backups are also no longer untracked.** `git ls-files` lists `inbox/backup/game.gd.bak-Y08`, `.bak-Y08b`, `terrain_tileindex.gdshader.bak-Y10`, `project.godot.bak-Y11`, `world3d.gd.bak-Z08`, `world3d_terrain.gd.bak-B04`, `world3d_relief.gd.bak-FOLD07`, etc. `[D]` From `git show --stat e234ac9b` + `git log --diff-filter=A`, `.bak-Y10`/`.bak-Y11` were added in `e234ac9b`, `.bak-Y08b` in `0e9783f2`. They are pre-change snapshots, **not** recoverable "uncommitted work".
4. **[D] A fresh terrain module's conflict surface is therefore entirely "already-landed machinery":** Y08/Y08b final-authority meadow collapse (`game.gd:2151-2166`), B03/L03 collision-only gradient pass (`game.gd:1274-1310`, only quarry disc still writes `terrain=5` at `:852`), Y07 widened smoothing guards (`game.gd:2333-2345`), Z08 read-only relief props (`world3d_relief.gd:3-8,86-253`), C01 derived `terrainmesh1..4` assets under `assets/models/{obj,tex}/shared/terrain/`, the tile atlas/shader/water modules and the stale Z07 QA atom. All are committed and clean; none may be re-patched by an implementation worker.
5. **[I] Highest double-apply risk is the seam**: A06 §2.1, V05 §4.2/§5 and untracked `IMPLEMENTATION_PLAN.md:19` (ticket I11) all claim `world3d.gd` (and A06/V05 also `main.gd`). No seam edit has landed yet (`:108` still holds only `TERRAIN_SCRIPT`; no `terrain_backend` symbol). COORD must name exactly one owner before any implementation wave; two workers applying the same additive seam would duplicate `set_terrain_backend()` and the `stats` keys. **No donor parity claim is made or implied.**

> [!IMPORTANT]
> Labels: **[O]** literal git/filesystem/read output; **[D]** deterministic consequence of [O]; **[I]** inference; **[U]** UNVERIFIED; **PORT APPROXIMATION** for port-authored substitutes. Hashes are SHA-256 of **working-tree bytes** (`Get-FileHash`, CRLF as stored); git blob ids are quoted separately where they resolve an apparent contradiction. No gate was run, so no gate claim is made.

---

## §0 Multiple-pass log (owner directive, CHARTER.md:85-93)

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | `git rev-parse --short HEAD`; `git status --short`; `git diff --stat`; `git diff --cached --stat`; `git diff --numstat` | HEAD `e234ac9b`; only two modified docs; `git diff -- game.gd` / shader / project.godot produced **no output** | Initial anomaly: contradicts A06 E12 (`HEAD=0e9783f2`, three `M` files) and P06 §5.1 |
| P2 | `git status --porcelain=v1 --untracked-files=no`; `git diff --exit-code -- variant3d/`; scoped status on `variant3d/` and three files | Only `docs/.../CHARTER.md`, `docs/.../spec/11_ASSET_CONVERSION.md`; `git_diff_variant3d_exit=0`; scoped status empty | Confirms anomaly is not a diff-filter artefact |
| P3 | `git hash-object` vs `git rev-parse HEAD:<path>`; `git show e234ac9b -- <three files>`; `git diff --no-index` of each file vs its `.bak-*` | `game.gd` hash-object `43c36a9b…` == HEAD blob; shader `9d6f2060…` == HEAD blob; project.godot `c495c4d0…` == HEAD blob. Commit diff shows exactly the Y08b/Y10/Y11 hunks. Backups differ by 1 hunk (Y10/Y11) or 3 hunks (Y08b) | Confirms edits are committed and backups are pre-change baselines |
| P4 | Third `git status --short` after more workers landed reports | HEAD still `e234ac9b`; `variant3d/` and `app/` still clean; `SWARM_BOARD.md` now modified (V04 row `:47` = RUNNING, V05 row `:48`); more untracked reports/specs | Doc-side concurrency only; port-file verdict stable |
| P5 | Byte/hash comparison of suspicious backups | `.bak-Y10` SHA `E02E787A…` **identical** to `.bak-B01b` SHA `E02E787A…` (both 30,133 B); `world3d_terrain.gd` SHA `983DA45F…` **identical** to `.bak-B04`; `game.gd.bak-Y08b` differs from HEAD~1 blob | All three reconciled: Y10 backed up the then-current B01b shader; B04 was fully reverted so backup == current; `.bak-Y08b` is *pre*-Y08b while HEAD~1 is Y08b-minus-scoping-fix |
| P6 | `git config --get core.autocrlf` → `true`; LF→CRLF git warnings | Working-tree byte SHA-256 values differ from git blob ids because of CRLF | Not a contradiction; both values are reported with their instrument so COORD does not mistake them for drift |

**[O] No anomaly was silently skipped.** The only unresolved items are listed in §8 as [U].

---

## §1 Evidence table (all [O] unless labelled)

| ID | Evidence | Observation | Consequence |
|---|---|---|---|
| E01 | `git rev-parse --short HEAD`; `git log -1 --format=%ci` | `e234ac9b`, 2026-11-26 08:56:33 +0100 | A06/P06's `0e9783f2` baseline is one commit stale |
| E02 | `git show --stat e234ac9b` | 19 files; includes `variant3d/project.godot` (+1), `variant3d/scripts/game.gd` (6 +/−), `variant3d/shaders/terrain_tileindex.gdshader` (2 +/−), `inbox/backup/project.godot.bak-Y11` (+28), `inbox/backup/terrain_tileindex.gdshader.bak-Y10` (+502) | The three in-flight edits and two backups landed together |
| E03 | `git status --short -- variant3d/`; `-- app/`; `git diff --exit-code -- variant3d/` | empty, empty, exit 0 | No port file needs backup-before-edit *for prior-wave reasons*; a fresh backup is still cheap audit insurance |
| E04 | `git diff --stat` | only `docs/.../CHARTER.md` (+9), `docs/.../spec/11_ASSET_CONVERSION.md` (+24/−2) at P1-P3; `SWARM_BOARD.md` modified by P4 | COORD/integration work is uncommitted; never blanket-restore |
| E05 | `variant3d/scripts/game.gd:382,388,393-398,2151-2166` | `g1`/`g0` = `test8`; scoping fix; final-authority collapse of ordinary land to `test8` | Y08/Y08b are live code, not pending patches |
| E06 | `game.gd:852`, `:854-859`, `:946-...`, `:1069`, `:1117`, `:1210`, `:1274`, `:1302-1310` | only quarry disc writes `terrain=5`; hill branch is height-only; relief writes `height[]` only; collision pass is `set_blocked_tile` only | Fresh module must not reintroduce art from relief |
| E07 | `game.gd:1604,1993,2008,2015,2251,2285,2333-2345,2348,2377` | donor smooth rules, `test8` neutralisation, 3-pass smoother, Y07 widened guards | Byte identity of legacy tileblock depends on these |
| E08 | `variant3d/shaders/terrain_tileindex.gdshader:43,60,180,235,328-335` | `unshaded`; `:60` = `filter_linear_mipmap_anisotropic`; `shadow_enabled` default 0; `mask_to_alpha` at `:235`; atlas cell lookup at `:328-335` | Only line 60 changed; A/B contract endpoints still present [D] |
| E09 | `variant3d/project.godot:28` | `textures/default_filters/anisotropic_filtering_level=4`; no MSAA/FXAA/TAA key | Y11 is a level-4 enum index, not donor parity |
| E10 | `variant3d/scripts/world3d.gd:108,113-116,133-139,213-226,609,614,642-645,649-650,674-692,741,748-751` | one `TERRAIN_SCRIPT`, one `RELIEF_SCRIPT`, six module vars, sole terrain construction at `:609`, bind/build gate at `:642-645`, relief at `:649-650`, stats at `:674-692`; no `terrain_backend` | Seam unapplied; exclusive choice must be at `:609` (V05 §4) |
| E11 | `variant3d/scripts/world3d_relief.gd:3-8,42-56,86-92,97-253,259-267,318-357` | read-only sim guard; reads `game.pattern_stamps`; `height_at_world()` for Y; authored scale; one `MultiMeshInstance3D` per sid named `TerrainmeshProps_<sid>`, group `terrainmesh_props`; mesh path via `AssetPaths.existing(sid,"obj")` with `LEGACY_OBJ_DIR` fallback warning | Z08 is a sibling consumer; do not replace or duplicate it |
| E12 | `git ls-files` over `assets/models/{obj,tex}/shared/terrain` + `variant3d/assets/terrain/mountain_props.json`; SHA values in §2 | `terrainmesh1..4` OBJ/MTL/PNG + `.import` all tracked; `mountain_props.json` tracked | C01 assets are committed baseline; no new copy needed |
| E13 | `variant3d/tests/t_relief_props_qa.gd:8-11,158,314-352` | header says Z07 expects one `MeshInstance3D` per prop while Z08 uses MultiMesh; `expected_pre_fix_failure: true` | Honest FAIL until reconciled; do not lower threshold to fake PASS |
| E14 | `git ls-files inbox/backup` + `git log --diff-filter=A` | all `.bak-Y*` / `.bak-Z08` / `.bak-FOLD07` / `.bak-B04` are tracked | P06 §5.1's "three backups untracked" is stale |
| E15 | `docs/terrain_swarm_2026-11-26/reports/V05_seam_reconciliation.md:32,77,213-217,259` | V05 independently found the stale git state, recorded V04 as `[U]`/not landed, and asked Q2 whether any hash discrepancy exists beyond it | This report answers V05 Q2: **none** (§5) |
| E16 | untracked `IMPLEMENTATION_PLAN.md:5,13,17,19-20`; `spec/12_QA_AND_INTEGRATION.md:9-11,37` | I11 claims `world3d.gd` seam; I05 mentions "mip fix per B02"; rollback recipe names `.bak-A06INT` | Two competing seam/backup ticket names; one owner must be chosen |
| E17 | `git status --short` over `inbox/backup`; `Test-Path` for five `.bak-V04` names | backup dir clean; all `.bak-V04` names absent at read | Safe for COORD to create the names in §7 (this ticket created none) |

---

## §2 SHA-256 evidence table (working-tree bytes; `Get-FileHash -Algorithm SHA256`)

| File | Bytes | SHA-256 | Baseline / backup (bytes; SHA-256) | Relation [O]/[D] |
|---|---:|---|---|---|
| `variant3d/scripts/game.gd` | 258,080 | `B4E4E8754EA2ED540544F6D30CC9E4A2B57407D43F82D4F380CAC49CECFD3B55` | `inbox/backup/game.gd.bak-Y08b` 257,818; `0009F025446BFC62706FCDF5B07B33539FF628CE87AF33193954B384A12EA64C` | Backup = pre-Y08b. `git diff --no-index` = 3 hunks (`:382` g1, `:393-398` scoping, `:2155-2156` mine mask) [O]. HEAD~1 blob `0a747b41…` [O] |
| `inbox/backup/game.gd.bak-Y08` | 256,802 | `B9D07265B250BC458D4FEA703452D1CD7F6FCC7B45C4DD888C19F10FD212D890` | — | pre-Branch-A; `.bak-Y08` → `.bak-Y08b` = +18/−1 lines [O] |
| `variant3d/shaders/terrain_tileindex.gdshader` | 30,145 | `F528612524165C618BB785B186535D0B023560D725C6783AF422E2623C05FEEC` | `inbox/backup/terrain_tileindex.gdshader.bak-Y10` 30,133; `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` | +12 bytes = length of `_anisotropic`; 1 hunk at `:60` [O]. HEAD~1 blob `4f4d00c6…` |
| `inbox/backup/terrain_tileindex.gdshader.bak-B01b` | 30,133 | `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` | equals `.bak-Y10` byte-for-byte [O] | Y10 backed up the B01b state; not a duplicate mistake |
| `variant3d/project.godot` | 1,012 | `FA2E4F5C26E1CED3A3B73F8CEE43C065EFAC845368C609543DE1DBC702B022D8` | `inbox/backup/project.godot.bak-Y11` 957; `6FFB4CDC3FA7040371FDAF414729C0CA5EDF3154953951F4A3A4E098F1248AFA` | +55 bytes = line `:28`; 1 insertion [O]. HEAD~1 blob `ff538805…` |
| `variant3d/scripts/world3d.gd` | 37,084 | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | `inbox/backup/world3d.gd.bak-Z08` 36,195; `DEF3A2E7766698387796B6A86B9C22D70E24251C8D9DBB8EC713732E6BC0CDD0` | Backup = pre-Z08 composition; current file already contains Z08 [D] |
| `variant3d/scripts/world3d_relief.gd` | 14,056 | `9368D7DFC0FF85B9DD2ACB2240FF62927FD4FA159091A2EA1D1DAC092EC6CEE1` | `inbox/backup/world3d_relief.gd.bak-FOLD07` 13,434; `357E21D043CDCBBBFE8F8270E6F5E43B04C41035EC26D73E04A64C48694910DE` | Backup = pre-FOLD-07 (flat path); current uses `AssetPaths.existing` [O] |
| `variant3d/scripts/world3d_terrain.gd` | 83,687 | `983DA45F2F72F262475917D212798F5C2176AB3B31CDE719F364538D15EFB04E` | `inbox/backup/world3d_terrain.gd.bak-B04` 83,687; **same SHA** `983DA45F…` | B04 fully reverted; backup == current byte-for-byte [O] |
| `variant3d/assets/terrain/mountain_props.json` | 66,519 | `D21237F43D2FD95DDD8FCD7A3AD14290C789DF1F1F3881DF8F35676053A0E500` | no `.bak-*` found | derived Z08 table; committed [O] |
| `variant3d/assets/models/manifest.json` | 320,756 | `CBC22B42D5E57139D3ECBA431AF0F4FCCD2D94FAB6105AC7124DD890BDE5F73D` | `inbox/backup/manifest.json.bak-C01ASSET`, `.bak-BUILDARTBATCH`, `.bak-INTREG` exist (different scopes) | Only bbox records matter to Z08 (`:318-338`) [D] |
| `.../obj/shared/terrain/terrainmesh1.obj` | 302,651 | `73AE92C1C58DF20F11FCBDFAF614496866F73E10E608D926F4BCD36A317C3242` | no `.bak-*` | C01/FOLD-07 asset [O] |
| `.../obj/shared/terrain/terrainmesh2.obj` | 256,005 | `C16CFBF1225AAACE77D742BD9922861E6B58FF863789AA599263A57F11D00E90` | no `.bak-*` | same |
| `.../obj/shared/terrain/terrainmesh3.obj` | 244,123 | `D01146BBA704BC31000C10C657D6E4FBD43DCB1EF7DBEA02311A47CBE8EAD7F6` | no `.bak-*` | same |
| `.../obj/shared/terrain/terrainmesh4.obj` | 342,497 | `983C34352C8AEA8B5806C320FE72E2EFD58C954466E8108649B5EB86F32ADE19` | no `.bak-*` | same |
| `variant3d/tests/t_relief_props_qa.gd` | 35,522 | `B3C7D1436F8EAA9035129625B483A73DC4ADBD321463A05A460A6122C383C524` | no `.bak-*` | stale Z07 atom [O] |
| `variant3d/scripts/main.gd` | 86,133 | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | many `.bak-*` (e.g. `.bak-LOADASYNC01`) | seam target; clean [O] |
| `variant3d/scripts/config.gd` | 32,219 | `160F08C098CF2F29172EAD66E4414A0C0291D7E338DB1798A41D8A777DE8F1A3` | many `.bak-*` | no stage-2 edit planned [D] |
| `variant3d/scripts/asset_paths.gd` | 3,384 | `935CE7DB760648F2AC87BD4E31AB04172D4ED66231D2E2E67F80317AD4A0DDEE` | no `.bak-*` | resolver used by Z08 (`:16,:66,:86`) [O] |

**[O] Verification:** `git hash-object variant3d/scripts/game.gd` = `43c36a9b4021786409530fb5d3212c3cc2bfcb9d` = `git rev-parse HEAD:variant3d/scripts/game.gd`; likewise shader `9d6f2060…` and project.godot `c495c4d0…`. Working-tree SHA-256 differs from the blob id only because `core.autocrlf=true` (P6).

---

## §3 Findings per file

### §3.1 `variant3d/scripts/game.gd` — Y08/Y08b + B03/L03/Y05/Y07 relief-tile authority

**[O] Current state (SHA above, clean at `e234ac9b`).** What it writes and which invariants it owns:

| Site | Writes | Invariant owned / evidence |
|---|---|---|
| `:42,:44,:52-53` | `terrain`, `height` (f32), `BLK_WATER=255`, `tileblock` (u8) grids | one uint8 tile id per cell; water id never overwritten (`:2153`) |
| `:79-80` | `_relief_stamp_mask` declared as diagnostic data | retained after B03/L03; no longer read by gradient pass (`:1302-1309`) |
| `:372-408` `_finalize_mine_tiles()` | `tileblock[mi]=g1` with `g1=_blk("test8")` at `:382`; start-disc `tileblock[ci]=g0` with `g0=_blk("test8")` at `:388`, guarded by radius ≤16.05 and `!=BLK_WATER` at `:393-398`; `set_blocked_tile(false)` at `:406` | Y08b PORT APPROX: visible meadow id only; `mine_mask`/`terrain` untouched. This is the exact hunk e234ac9b committed |
| `:852` | `terrain[ii]=5` in the **stone quarry disc** (`dc<=1.6`) | only surviving executable `terrain=5` write; hill branch `:854-859` explicitly height-only after B03/L03 |
| `:946-...` `_shape_stamp_relief()` | allocates `_relief_donor_mask`/`_relief_stamp_mask`; stamps donor-grid height at `:1069` (`clampf(..., RELIEF_RAVINE, RELIEF_PLATEAU)`), analytic fallback at `:1117`, RCODE height at `:1210`, 8-bit-dithered plateau clamp at `:1274`; called before collision | **height-only producer**; no tile id and no `terrain` write from relief; PORT APPROX blend |
| `:1274-1310` | `set_blocked_tile(x,y,true)` for every steep cell, unconditional; 0.03 dither cap on plateau; no `terrain=5` (comments `:1302-1309`) | collision/art separation; `scan_map`, starts and walkability depend on it. Do not re-enable the B04 face promoter or the gradient `terrain=5` paint |
| `:1604` `DONOR_SMOOTH_RULES`; `:2251` `_tb_pick`; `:2285` `_tb_smooth_pair`; `:2348` `_smooth_tilemap(...,3)` | transition tile ids via the donor rule list, 3 passes | Y07 guards at `:2333-2345` exclude **both** `test8` and `grass9`; reverting to a single id restores the ring halo |
| `:1993,:2008` | `tex = _blk("test8")` neutralisation in detail pass | Y05 change; do not revert to `grass9` (restores corrugation) |
| `:2015-2168` `_assign_tileblocks()` | final authority after smoothing: skip `BLK_WATER` (`:2153`), mine apron → meadow (`:2155-2156`), skip roles 1/3/4/5 (`:2159-2161`), all ordinary land → `meadow_id` (`:2162`); winter alias at `:2168-2170` | Y08 checkboard fix; `_blk()` draws no RNG; no `terrain`/`height`/`blocked` write (`:2149-2150`) |
| `:2377+` `_stamp_grass_spots()` | L01 spot ids from `[grass1, grass9, test7, test8, test9]` | spatial trigger; final-authority collapse neutralises its visible colour on ordinary land |

**[O] Backups:** `.bak-Y08` (pre-Branch-A), `.bak-Y08b` (pre-Y08b). **[D]** Restoring either **reverts committed work**; neither is an "uncommitted edit" to preserve (§0 P3/P5).

### §3.2 `variant3d/shaders/terrain_tileindex.gdshader` — Y10 one-line anisotropy hint

**[O] Current state (SHA above, clean).** `:43` `render_mode blend_mix, unshaded, cull_disabled;`; `:60` `uniform sampler2D tile_atlas : filter_linear_mipmap_anisotropic, repeat_enable;` (the sole Y10 hunk); `:180` `uniform float shadow_enabled = 0.0;`; `:235` `uniform float mask_to_alpha = 1.0;`; `:328-335` atlas cell lookup + half-texel inset. The comment block above `:60` is deliberately stale about the hint. `[D]` All protected anchors cited by P06 §5.1 (`:235`, `:365-378`, `:392`, `:410-419`, `:427`, `:475`, A/B `:478-502`) remain, so both `mask_to_alpha` A/B endpoints are still one compiled program — but **the anisotropy A/B itself is APPLIED_NOT_CAPTURED [U]**; anisotropy is PORT APPROX vs donor `tfIsotropic` (Y10/Y11 via P06 §4 V-27).

**[O] Backups:** `.bak-Y10` SHA `E02E787A…`, byte-identical to `.bak-B01b` (§0 P5); HEAD~1 blob `4f4d00c6…`. **[D]** Do not "restore the shader to pre-Y10" as part of unrelated rollback, and do not stack further shader edits before the matched-camera A/B.

### §3.3 `variant3d/project.godot` — Y11 anisotropy level

**[O] Current state (SHA above, clean).** `:28` `textures/default_filters/anisotropic_filtering_level=4` — enum index for 16x, not the literal `16`; no MSAA/FXAA/TAA key. Backup `.bak-Y11` SHA `6FFB4CDC…`, HEAD~1 blob `ff538805…`. **[D]** New terrain module needs no project setting; do not normalise this line during any rollback. PORT APPROX, not donor parity.

### §3.4 `variant3d/scripts/world3d_relief.gd` — committed Z08 relief-prop consumer

**[O] Current state (SHA above, clean).** It writes **only scene nodes and `stats`**: `:3-8` read-only guard (no `height[]`, `blocked[]`, RNG, stamp mutation); `:42` `PROP_TABLE`, `:43` `MODEL_MANIFEST`, `:47` `AssetPaths`, `:48` `DONOR_UNITS=160`, `:49` `TILE_M=2`, `:50` `GROUP="terrainmesh_props"`, `:51` `RELIEF_SIDS=[terrainmesh1..4]`; `bind()` `:86-92`; `rebuild()` `:97-253` reads `game.pattern_stamps` (`:121-129`), derives `cell_scale=MAP_W/160` (`:137`), world X/Z via stamp centre + donor-cell offset (`:175-181`), Y from `terrain.height_at_world()` (`:183-184`), applies **authored** uniform donor Scaling (`:186-189`, no random rescale), builds one `MultiMesh` per sid (`:206-246`) named `TerrainmeshProps_<sid>` with `scale_authored`/`selection_rule` metadata; stats at `:248-253`; QA seams `set_props_visible()` `:259-262` and `props()` `:266-267`; bbox from manifest `:318-338`; mesh loading through `AssetPaths.existing(sid,"obj")` `:347` with `LEGACY_OBJ_DIR` fallback warning `:348-349`. **[I]/PORT APPROX:** placement and `terrainmeshN` selection are engine-side UNVERIFIED; no donor parity claim.

### §3.5 C01/Z08 derived assets — committed, clean

**[O]** `variant3d/assets/terrain/mountain_props.json` (SHA above) is the derived 112-record table; `terrainmesh1..4` OBJ/MTL/PNG plus `.import` files are tracked under `variant3d/assets/models/obj/shared/terrain/` and `variant3d/assets/models/tex/shared/terrain/` (SHAs above); `asset_paths.gd:16,66,86` maps/legacy-resolves them. **[D]** A fresh props module (A06 N5 / IMPLEMENTATION_PLAN I09) must **reuse** these; rebuilding/copying them under a new name would create duplicate silhouettes. No `.bak-*` baseline exists for these derived files — they are additions, not edits.

### §3.6 `variant3d/scripts/world3d_terrain.gd` + `variant3d/tests/t_relief_props_qa.gd`

**[O]** `world3d_terrain.gd` clean, SHA `983DA45F…` **equal to `.bak-B04`** (§0 P5). Constants `:130` `TILE_M=2.0`, `:131` `HEIGHT_SCALE=1.0`, `:132` `WATER_LEVEL=-0.25`; `_face_mode_at()` `:756` uses verbatim `cDiff` with **no** `_relief_face_at()`; `_dump_from_game()` `:926-963`, `_decode_tile_indices()` `:969-995`; water plane `:1055-1085` and `:1102-1104` (`WaterPlane` rename); `build()` `:1220`; mesh vertices `:1310-1312` and UV2 `:1315-1316`; `shadow_enabled=0` `:1160`; `height_at_world()` `:1722-1738`. `[D]` B04 revert is byte-perfect; do not re-apply B04.
**[O]** `t_relief_props_qa.gd:8-11,158,314-352` is still the pre-MultiMesh Z07 atom expecting one `MeshInstance3D` per prop and carries `expected_pre_fix_failure: true`. **[D]** It will FAIL closed until reconciled by an owner; that is an honest FAIL, not a regression to hide.

### §3.7 Uncommitted docs (context, not port files)

**[O]** At P4: modified `docs/terrain_swarm_2026-11-26/CHARTER.md` (adds the multiple-pass directive at `:85-93`), `SWARM_BOARD.md` (V04 row `:47`, V05 `:48`, more status changes), `spec/11_ASSET_CONVERSION.md` (adds §11.7 "Legacy tool disposition (from P04)"); untracked `IMPLEMENTATION_PLAN.md`, `reports/A04_landscape_props.md`, `A05_qa_harness.md`, `A06_integration.md`, `F02_pattern_lib.md`, `F03_gen_config.md`, `F05_tile_mapping.md`, `F06_alpha_masks.md`, `P01_pipeline_audit.md`, `P03_gates_capture.md`, `P04_tool_audit.md`, `P05_2d_reuse.md`, `P06_prior_wave_distill.md`, `V05_seam_reconciliation.md`, `spec/01,04,06,08,09,10,12,13,14`. `[D]` The list grows as workers land; re-read before integrating. **[U]** Any later doc edit may change the conflict register; this report is a point-in-time audit of HEAD `e234ac9b`.

---

## §4 Conflict / double-apply register

| # | Item | Observed state [O]/[D] | Double-apply risk | Avoidance for implementation workers |
|---|---|---|---|---|
| C1 | Y08b `game.gd` | committed at `e234ac9b`; `:382,:388,:393-398,:2151-2166` live; `.bak-Y08b` pre-change | **HIGH** — P06 §5.1/A06 §2.6 still describe it as uncommitted; a worker may re-apply hunks or "restore" the backup | Treat as landed baseline; zero edits to `game.gd`; new module read-only on sim |
| C2 | Y10 shader / Y11 project.godot | committed at `e234ac9b`; `:60` and `project.godot:28` live | **HIGH** — same stale reports list them as `M`; re-applying yields a duplicate line or invalid enum literal | New shader file only (A06 N7 / PLAN I10); no project.godot edit; do not stack shader changes before A/B |
| C3 | Z08 relief props | committed `world3d_relief.gd` + `world3d.gd:113-116,614,649-650` | MEDIUM-HIGH — I09/N5 may instantiate a second `terrainmesh` layer | Reuse `TerrainmeshProps_*`; one MultiMesh per sid; keep `relief.bind()` unchanged; props-ON/OFF via `set_props_visible()` |
| C4 | C01 derived `terrainmesh*` assets | committed under `assets/models/*/shared/terrain/`; all SHAs in §2 | MEDIUM — I05 atlas rebuild or I09 props may overwrite/copy | Read-only reuse via `AssetPaths.existing`; no donor binary copied (CHARTER.md:26-30) |
| C5 | B03/L03 collision-only gradient pass / Y05/Y07 guards | committed `game.gd:1302-1310,1993,2008,2333-2345` | **HIGH** — re-enabling `terrain=5` or the B04 face gate recreates the maze (P06 §6 #1/#5/#7) | Do not promote faces; do not lower a threshold; height-only producer; collision separate from art |
| C6 | TRN-GEOM/SHADER/WATER/DATA baseline | clean at HEAD (A06 §2.6 `:258`, V05 §4.3 `:145`) | MEDIUM — re-applying those diffs duplicates literals | Compose `water3d.gd` read-only; do not duplicate donor water literals into a second implementation |
| C7 | P16 optimisation proposal | never applied; A06 §2.6 `:259` | LOW-MEDIUM — `git apply` onto today's tree would conflict with Y08b | Out of scope; re-base and take a fresh backup only under a new COORD ticket |
| C8 | Seam ownership | `world3d.gd:108,609` unchanged; A06 §2.1, V05 §4.2/§5 and PLAN I11 all claim it | **HIGH** — two workers applying the same additive inserts duplicate `set_terrain_backend()` and `stats` keys | Single COORD-named owner; exclusive ternary at `:609`; both `make_world3d()` sites; default `"legacy"` |
| C9 | Anisotropy A/B | Y10/Y11 committed, **APPLIED_NOT_CAPTURED** [U] | MEDIUM — treating anisotropy as a landed fix or stacking MSAA/FXAA | Port approximation only; if null A/B, record it and do not stack further shader edits (P06 §4 V-27) |
| C10 | Z07 QA atom | stale, expects per-prop `MeshInstance3D` (E13) | LOW — "fixing" it by lowering `expected` fakes a PASS | Reconcile collector/count by strengthening; keep `expected_pre_fix_failure: true` until then |
| C11 | Stale report registers | A06 E12/E13, P06 §5.1, V05 §6/E25 all stale on git state / V04 landing | MEDIUM — wrong edit location or destructive restore | Re-read `git status` + this report immediately before any edit; V05 Q2 answered in §5 |
| C12 | Concurrent doc edits | CHARTER/SWARM_BOARD/spec11 modified; reports untracked (E04/E17) | MEDIUM — blanket git restore loses them | No `git reset --hard`, `git checkout -- .`, `git clean -fd`; file-scoped `Copy-Item` only |

---

## §5 Implications for the A06 seam (V05 Q2 answer)

1. **[O] V05 Q2 (`V05_seam_reconciliation.md:259`) asks whether V04 finds any source-file hash discrepancy beyond the stale A06 E12 register. Answer: NO.** All 17 port files hashed in §2 match HEAD (blob-id equality via `git hash-object` / `git rev-parse HEAD:<path>`); `git diff --exit-code -- variant3d/` = 0 in passes P1-P4. The `.bak-Y08b`/`.bak-Y10`/`.bak-Y11` values are pre-change snapshots, not evidence of pending edits.
2. **[D] A06's §3.4 "forbidden" list remains the correct discipline but its rationale has changed.** It was written to protect uncommitted Y08b/Y10/Y11 work; those edits are now committed. The live reason to avoid blanket git restore is the uncommitted **docs** work (§3.7) and the need to preserve any future worker's in-flight file. Keep file-scoped `Copy-Item` + recorded SHA-256 as the only rollback mechanism.
3. **[D] A06 §3.1 `.bak-A06INT` and IMPLEMENTATION_PLAN's generic `.bak-<TICKET>` are still the right backup names for seam files — but copy the *working tree* file, not `git show HEAD:...`.** At this read the working-tree seam files equal HEAD, so both are equivalent; that equivalence may not hold once a worker starts editing. Naming collision risk: A06 proposes `A06INT`/`A06MOD`, V05/PLAN propose I11; COORD must reserve one suffix (§8 Q3).
4. **[D] The seam is unapplied and must stay exclusive.** `world3d.gd:609` still instantiates `TERRAIN_SCRIPT` only; there is no `terrain_backend` symbol. Add the donor as a ternary at `:609`, never as a third sibling (two meshes / two water planes / two `WorldEnvironment` nodes). Keep `:642-645`, `:649-650`, `:741`, `:748-751` unchanged so Z08 relief and the dump contract keep working.
5. **[D] Legacy-mode byte identity is now anchored to `e234ac9b` including Y08b/Y10/Y11.** Any A/B that reports "legacy changed" against `0e9783f2` is comparing against a stale baseline. Record the current SHAs from §2 as the legacy reference before stage 2.
6. **[U] Whether `stats.terrain_backend` affects an atom that snapshots the whole `stats` dict is unresolved** (V05 §8 item 8); additive keys only, then run the gate battery.

---

## §7 Exact backup / rollback commands for COORD (NOT executed by V04)

All commands are PowerShell, run from the repo root. **[O]** At this audit none of the five `.bak-V04` names exist, so creating them is safe. **[D]** Never overwrite an older ticket's backup; never use `git reset --hard`, `git checkout -- .`, `git clean -fd`, or `git show HEAD:<path>` as a restore source.

### §7.1 Pre-edit backup — file-scoped, ticket `V04`

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
git status --short; git rev-parse --short HEAD
Copy-Item -LiteralPath 'variant3d\scripts\game.gd'                       -Destination 'inbox\backup\game.gd.bak-V04'                       -Force
Copy-Item -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader'   -Destination 'inbox\backup\terrain_tileindex.gdshader.bak-V04'   -Force
Copy-Item -LiteralPath 'variant3d\project.godot'                        -Destination 'inbox\backup\project.godot.bak-V04'                -Force
Copy-Item -LiteralPath 'variant3d\scripts\world3d.gd'                   -Destination 'inbox\backup\world3d.gd.bak-V04'                  -Force
Copy-Item -LiteralPath 'variant3d\scripts\world3d_relief.gd'            -Destination 'inbox\backup\world3d_relief.gd.bak-V04'           -Force
Get-FileHash -Algorithm SHA256 -LiteralPath 'inbox\backup\game.gd.bak-V04','inbox\backup\terrain_tileindex.gdshader.bak-V04','inbox\backup\project.godot.bak-V04','inbox\backup\world3d.gd.bak-V04','inbox\backup\world3d_relief.gd.bak-V04' | Format-Table -AutoSize
```

Expect the five hashes to equal the "File" column of §2 (`B4E4E875…`, `F5286125…`, `FA2E4F5C…`, `44EE96C0…`, `9368D7DF…`) because the files are clean at `e234ac9b`. If they differ, **STOP** — another worker has started editing; record the new values and re-audit.

### §7.2 Rollback of implementation edits to the audited baseline

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-V04'                     -Destination 'variant3d\scripts\game.gd'                     -Force
Copy-Item -LiteralPath 'inbox\backup\terrain_tileindex.gdshader.bak-V04'  -Destination 'variant3d\shaders\terrain_tileindex.gdshader'  -Force
Copy-Item -LiteralPath 'inbox\backup\project.godot.bak-V04'               -Destination 'variant3d\project.godot'                      -Force
Copy-Item -LiteralPath 'inbox\backup\world3d.gd.bak-V04'                  -Destination 'variant3d\scripts\world3d.gd'                 -Force
Copy-Item -LiteralPath 'inbox\backup\world3d_relief.gd.bak-V04'           -Destination 'variant3d\scripts\world3d_relief.gd'          -Force
Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\game.gd','variant3d\shaders\terrain_tileindex.gdshader','variant3d\project.godot','variant3d\scripts\world3d.gd','variant3d\scripts\world3d_relief.gd' | Format-Table -AutoSize
git status --short -- variant3d/; git status --short -- app/
```

Acceptance: hashes match §2; `git diff --exit-code -- variant3d/` returns 0; `app/` empty. **[D]** This restores *today's committed baseline including Y08b/Y10/Y11* — it does **not** undo prior waves.

### §7.3 Optional, explicitly different operation — revert a committed prior-wave edit

**[D]** Do this only on a separate owner decision; it rewrites committed work and would make legacy-mode output differ from the `e234ac9b` reference.

```powershell
# Revert Y08b only -> pre-Y08b state (loses the committed scoping fix and g1/g0 meadow ids)
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y08b' -Destination 'variant3d\scripts\game.gd' -Force
# Revert Y10 only -> pre-Y10 shader (backed-up state is byte-identical to .bak-B01b)
Copy-Item -LiteralPath 'inbox\backup\terrain_tileindex.gdshader.bak-Y10' -Destination 'variant3d\shaders\terrain_tileindex.gdshader' -Force
# Revert Y11 only -> pre-Y11 project settings
Copy-Item -LiteralPath 'inbox\backup\project.godot.bak-Y11' -Destination 'variant3d\project.godot' -Force
# Revert Z08 composition / FOLD-07 path migration (separate, wider consequences):
Copy-Item -LiteralPath 'inbox\backup\world3d.gd.bak-Z08' -Destination 'variant3d\scripts\world3d.gd' -Force
Copy-Item -LiteralPath 'inbox\backup\world3d_relief.gd.bak-FOLD07' -Destination 'variant3d\scripts\world3d_relief.gd' -Force
# B04 backup is byte-identical to current world3d_terrain.gd: restoring it is a NO-OP, not a rollback
```

### §7.4 Forbidden

```powershell
# DO NOT RUN — destroys uncommitted docs work and/or prior-wave committed fixes:
# git reset --hard
# git checkout -- .
# git clean -fd
# Copy-Item <(git show HEAD:variant3d\...)> <destination>
```

**[D]** Post-rollback gate battery is COORD-owned (A06 §2.4 stage 2; V05 §4.3): selftest 29/29, uitest 17/17, `t_render_mode` 10/10 `seam_missing=false`, `t_terrain_only`, `t_terrain3d`, `assert_clean CLEAN`, `git status --short -- app/` empty. **No gate outcome is claimed by V04.**

---

## §8 UNVERIFIED register

1. **[U]** No donor binary/data/frame, Godot process, runner job, capture or gate was used; no donor parity claim, no PASS claim.
2. **[U]** This is a point-in-time audit of HEAD `e234ac9b`. Concurrent workers are landing docs (§3.7); a new commit could change HEAD before implementation. Re-read before any edit.
3. **[U]** Whether COORD reserves `.bak-V04`, `.bak-A06INT`/`.bak-A06MOD` or an `I##` ticket suffix for seam files (C8, §5 item 3). None of the `.bak-V04` names was created by this ticket.
4. **[U]** Whether the Y10/Y11 anisotropy A/B is null; if so, P06 §4 V-27 requires recording it as tile-id/patch data and not stacking shader changes.
5. **[U]** Whether the donor module can satisfy `_has_height_source()` (`world3d.gd:231-238`), the UV2 `[0,123]` / atlas `[16,8]` contract and the single-`WaterPlane` invariant without a new owner-approved contract (V05 §8 items 7-8).
6. **[U]** Whether `mountain_props.json` / `terrainmesh1..4` placement is visually correct; Z08/C01 are committed but UNVERIFIED (P06 §5.2, Z08 §6). The stale Z07 atom remains an honest FAIL.
7. **[U]** The relation between `.bak-Y08` and HEAD~1 was checked by line-diff, not by a byte-for-byte restore simulation; no file was modified to test it.
8. **[U]** Whether any atom snapshots the whole `stats` dict (additive seam keys risk) — V05 §8 item 8, not exhaustively enumerated here.

---

## §9 Open questions for COORD

1. **Q1.** Confirm that Y08/Y08b/Y10/Y11 are final landed baseline and instruct all implementation workers to stop treating the P06/A06 "uncommitted" register as a patch list (C1/C2, §5 item 1).
2. **Q2.** Name the single owner of `main.gd` + `world3d.gd` and reserve one backup suffix before any seam work; A06/V05/PLAN I11 currently overlap (C8, §8 Q3).
3. **Q3.** Should COORD create the `.bak-V04` snapshots in §7.1 immediately, or fold them into the chosen seam ticket's backup set? (V04 created none, by design.)
4. **Q4.** Should the optional §7.3 reverts ever be exercised (they change committed legacy behaviour and invalidate the `e234ac9b` byte reference)? Recommended: no, except under an explicit owner ticket.
5. **Q5.** Who reconciles the stale Z07 `t_relief_props_qa.gd` atom by strengthening it, and when — before or after the donor props module lands (C10)?
6. **Q6.** Should V05's E25/Q2 and spec/13's note about V04 be updated now that this report lands? (V04 does not edit those files; COORD integrates.)
7. **Q7.** If a donor-mode props module is added, is `world3d_relief.gd` still bound at `world3d.gd:649-650` in donor mode, or is that a separate approved contract change (V05 Q8)?

---

## §10 Handoff summary (5 lines)

1. **Verdict:** HEAD is `e234ac9b` and every port file is clean; the Y08b/Y10/Y11 "uncommitted" conflicts in P06 §5.1 and A06 E12/E13 are stale and were committed, so they must not be re-applied.
2. **Hashes/evidence:** exact SHA-256 values for 17 port files, `.bak-Y08`/`.bak-Y08b`/`.bak-Y10`/`.bak-Y11`/`.bak-Z08`/`.bak-FOLD07`/`.bak-B04` baselines in §2; `.bak-Y10` == `.bak-B01b` and `.bak-B04` == current `world3d_terrain.gd` (6 passes recorded in §0).
3. **Landed machinery:** Y08/Y08b final-authority collapse (`game.gd:2151-2166`), collision-only gradient pass (`:1274-1310`), Y07 guards (`:2333-2345`), Z08 read-only MultiMesh props (`world3d_relief.gd:3-8,86-253`) and committed C01 `terrainmesh1..4` assets coexist by composition, not patching.
4. **Risks:** highest double-apply risk is the unapplied seam (`world3d.gd:108,609`) claimed by A06, V05 and PLAN I11; only uncommitted state is in `docs/`, so blanket git restore remains forbidden (§4 C1/C2/C8/C12).
5. **Rollback:** file-scoped `.bak-V04` backup/restore commands are in §7 for COORD only; no `.bak-V04` was created, no source/git state changed, no gate run, and **no donor parity claim** is made (PORT APPROXIMATION / UNVERIFIED throughout).

*End of V04 report. Exactly one report written; no source, shader, config, asset, test, backup, git, runner, Godot, donor or `app/` state changed.*
