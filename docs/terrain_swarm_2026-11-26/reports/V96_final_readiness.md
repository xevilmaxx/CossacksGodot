---
id: V96
ticket: "TERRAIN-SWARM-2026-11-26 / V96 — FINAL consolidated readiness sweep AFTER the B1–B4 fixes"
agent: "V96 (read-only final readiness subagent, 30-agent DONOR-FIRST terrain swarm; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_GATE_RUN__NO_RUNNER_SUBCOMMAND__NO_GODOT__NO_SOURCE_EDIT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V96_final_readiness.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V96_final_readiness.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner subcommand, gate, capture or result JSON was produced by V96. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Every PASS below is a CURRENT-BYTES filesystem/file:line/static prerequisite verdict — NOT a gate result and NOT a donor-parity claim."
scope_guard: "Read-only: file reads, PowerShell Get-ChildItem/Test-Path/Get-FileHash/Select-String, git read commands, Python json.load / os.walk / string scans. No .bak, source, shader, asset, test, manifest, config, queue, app/, git or Godot state touched."
multiple_passes: true
snapshot: "2026-11-26, final pass. Live concurrent swarm: V86/V89/V90/V95 landed during the sweep, and terrain_new/manifest.json plus a 5th-tier state change landed between two V96 passes. Authority = the LAST pass; every count/hash is point-in-time and COORD must re-glob/re-hash immediately before acting."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V96 — FINAL consolidated readiness sweep (after B1–B4 fixes)

## 0. Method and reading rule

Every row of §2 was checked with **two independent commands**: instrument A =
PowerShell `Test-Path` / `Get-ChildItem` / `Select-String` / `ConvertFrom-Json` /
`Get-FileHash` / git read commands; instrument B = Python `json.load` / `os.walk`
/ targeted line reads / string scans. Disagreements were re-run until the live
tree, not a stale report, was authoritative (CHARTER.md:85-93).

`CLEARED` = the prerequisite is satisfied in **current bytes** as a filesystem
or static observation. `OPEN` = it is not. Neither word means a gate PASS.
`[O]` observation · `[D]` deterministic consequence · `[U]` not establishable
without Godot. **No gate was run and no donor-parity claim is made.**

Named-report availability at the final glob: `V86_final_go_no_go.md`,
`V89_final_asset_seal.md`, `V90_static_syntax_seal.md` and
`V95_registration_verification.md` **are PRESENT** (they landed during this
sweep; earlier V96 passes found some absent). There is **no standalone V94
report file** — the V94 path-correction *pass* is recorded inside
`V42_gate_commands.md:27`. V86/V90 were themselves point-in-time and are
superseded here wherever the live tree moved on (B1 spec path, B5 V55 record,
B4 root manifest).

## 1. Verdict in one line

**NO-GO** for running the V42 gate packet unchanged. B1, B2, B3, the B5 record,
V83 hygiene, all five V58 I07 findings, V61's six API pairs, and seam/backups/app
are **CLEARED** in current bytes. Still **OPEN**: the I09 object-feed path/shape,
the missing schema, the unexecuted 575/582/585 acks, and the optional 320²
determinism size. Exact ordered blockers are in §4. **No gate run, no parity
claim.**

## 2. Consolidated blocker table — blocker → original source → CURRENT status → evidence → 2nd instrument → remaining owner

| # | Blocker | Original source | CURRENT status | Evidence (file:line / command) | 2nd instrument (verification command) | Remaining owner / action |
|---|---|---|---|---|---|---|
| B1-a | Gate packet shader path non-resolving | V76 §3 B1 (`V76_gate_preflight.md:61`); V42 §4.5 old `variant3d\shaders\terrain_donor.gdshader` | **CLEARED** | `V42_gate_commands.md:27` (V94 correction), `:185` `Get-FileHash … variant3d\shaders\terrain_donor_shader.gdshader`; `Test-Path` canonical = True, old alias = False | Python scan of all executable `Test-Path `/`Get-FileHash ` lines in V42 (`:174,175,176,177,185,230,277,345`): old bad literal occurs **0** times | None. Keep the 28 unique ids |
| B1-b | Gate packet spec path non-resolving | V76 §3 B1 (`V76_gate_preflight.md:61`); V42 §4.4 old `variant3d\spec\terrain_qa_spec.json` | **CLEARED** (V86 row 17 now stale) | `V42_gate_commands.md:29,177` `Test-Path docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json`; `Test-Path` canonical = True, `variant3d\spec\...` = False | Python line scan: `Test-Path variant3d\spec\terrain_qa_spec.json` as a command → 0 hits | None. N17 is SCHEMA-ONLY — advisory, never a PASS |
| B2 | I12 test not registered (40→41) | V76 §3 B2 (`:62`); V11 §8 / V42 §4.6 E13 | **CLEARED** | `variant3d/tests/manifest.json` → `COUNT=41`, `LAST=t_terrain_donor`; entry at `:332-339` (`id :333`, six fields, `ready`); V95 §2 item 1 | Python `json.load`: `COUNT 41 LAST t_terrain_donor TDONOR 1`; corroborated by V95's `ConvertFrom-Json` + difflib (append-only, first 40 identical) | None for registration. *(Backup `tests_manifest.json.bak-I12` absent — V95 §4.1; rollback must remain id-level removal)* |
| B3 | GR-A24 atoms points at absent `terrainmesh_props.json` | V76 §3 B3 (`:63`); V13 `:18,51` | **CLEARED** | `variant3d/tests/t_relief_props_qa.gd:30` `const PROP_MANIFEST := "res://assets/terrain/mountain_props.json"  # V13: live file; old terrainmesh_props.json absent`; live `mountain_props.json` = True, old = False; thresholds `:41 BBOX_TOL=0.05`, `:42 SCALE_WANT=1.0`, `:43 SCALE_TOL=0.02`, `:158 expected_pre_fix_failure=true` unchanged | Python line re-read of `:30,41,42,43,158` + `os.path.exists` of both targets; V95 §2 item 2 difflib: only line 30 of 795 changed | None. Do not lower thresholds; atom result itself is still NOT_RUN |
| B4-atlas | Rendered atlas tier absent (I05 dry-run) | V76 §3 B4 (`:64`); V62 §6 P0; V66 | **CLEARED** (presence + static resolution) | `terrain_new/atlas/`: `tile_index_atlas.png` 4,211,707 B, `tile_index_atlas.manifest.json` 149,449 B, `alpha.png`, `alphavert.png`, `seasons/*`; I08 constants `terrain_donor_mesh.gd:57-59` resolve to disk; `_atlas_paths():367-383` takes the `terrain_new` branch | Python `os.walk` of atlas (8 files) + manifest key probe (`atlas.grid`, `layout`, `visual_parity_claim:false`); V89 §5.1 static load compatibility | None for presence. `[U]` real GPU load is COORD's Godot job |
| B4-masks | Derived masks tier absent / X19 layout gap | V62 §3.4; V76 §3 B4; X19 | **CLEARED** (presence/index) | `terrain_new/masks/mask_index.json` PRESENT (11,680,098 B; `source` = `"data/gen"`); `masks/height/**` 4,466 PNGs across vanilla/dlc5/src families | Python `json.load` of `mask_index.json` + `os.path.exists` of a sampled height PNG; PowerShell `Test-Path` agrees (both True) | None. V89 §2 records PASS at its snapshot |
| B4-lib | No I09-usable object feed; lib index at wrong path/shape | V62 C1/C2; V66-F1/V66-F3; V89 §5.2; V86 row 9 | **OPEN** | `terrain_new/lib/pattern_lib_index.json` PRESENT (55,784,815 B, top keys include `generator_families` list, **no** `props/objects/Objects/records/by_pattern` dict); I09 `terrain_donor_props.gd:59` `FEED_LIB_INDEX` = `res://assets/terrain_new/patterns/pattern_lib_index.json` → **ABSENT**; `_try_feed():569-607` would accept `generator_families` as a bare Array key and yield `_records["generator_families"]` → false provenance (V66-F1); `:61` legacy `mountain_props.json` fallback is currently effective (`fallback_used=true`) | Python `json.load` key probe of the lib index (`props=None`, `generator_families=list len 64`) + `os.path.exists` of both candidate paths; PowerShell `Test-Path`: lib True, patterns False | **I03 + I09 + COORD**: one canonical path and one `_try_feed()`-accepted record shape; assert feed under `terrain_new` and `fallback_used=false`. Do not invent per-pattern tails |
| B4-manifest | X15 root `manifest.json` absent | V62 §3 #1; V66; V76 §3 B4; V89 §3 (P0) | **CLEARED** (landed mid-sweep; V89's P0 #1 overtaken) | `terrain_new/manifest.json` PRESENT (6,450,422 B): `schema="terrain_new/manifest/v1"`, `pack_id="terrain_new_v1-b7984b3cb162cdf9"`, `entries` list (5,256), `asset_index`, `visual_parity_claim=false`, `commit_policy`, `census_reference` | Python `json.load` key/type probe + PowerShell `Test-Path`; both True. Census now **5,257 files / 364,646,949 B** (old 5,256 + the manifest itself) by both Python `os.walk` and PowerShell `Get-ChildItem` | None for presence. `[U]` pack still volatile and 0 files tracked — re-census immediately before commit |
| B4-schema | `schemas/v1.schema.json` absent | V89 §6 #2 / §7 reason 3; V11 G11 | **OPEN** | `Test-Path terrain_new\schemas\v1.schema.json` = False; Python `os.path.exists` = False | Same two commands agree | **I05 / G11**: land the schema or explicitly retire G11 with COORD sign-off |
| B5 | No recorded Python preflight exit codes | V76 §3 B5 (`:65`); V42 §4.3 | **CLEARED** as a record (V55 landed after V86/V90) | `reports/V55_python_preflight.md` PRESENT; `:25` all six self-checks exit 0 on final pass; `:28` `python -m py_compile` on six tools exit 0 twice (temp `PYTHONPYCACHEPREFIX`); `:64-72` exact exit-code table; F1 transient `NameError` re-run, not skipped (`:26,80`) | PowerShell recursive `*preflight*`/`*V55*` search + `Test-Path`; Python report read of `:25,28,64-72`; both confirm the file and the recorded codes | **COORD**: re-run V42 §4.3 `py_compile` at A′-1 on the **current** tree — V55's codes are keyed to its own source hashes (V55 E10) and the tree has drifted since |
| V83 | Absolute donor install paths emitted into generated JSON | V83 §5/§9 (`:23,235`); V28 F-07; V49; V62 C4 | **CLEARED** at current bytes | 0 JSON files under `terrain_new/**` contain `C:\Games\Cossacks 3`; `cfg/manifest.json:235` `"game_root": "$COSSACKS3_DIR"`; `patterns/pattern_decode_manifest.json:4` `"donor_root": "$COSSACKS3_DIR"`; V89 §4.1 0/786 after a forward-slash transient in `masks/mask_index.json:3` was normalised | PowerShell `Select-String -SimpleMatch 'C:\Games\Cossacks 3'` over 785 (now 786+) JSONs → 0; Python regex/needle scan → 0 for both slash forms | None current. **Caveat:** source emit sites `decode_donor_cfg.py:673`, `decode_pattern_lib.py:1041`, `decode_donor_pattern.py:944` still interpolate the resolved root — COORD must re-scan after any regeneration |
| V58-3d | I07 omits `plt2=2222` / `8225` grid offsets | V58 §1 item 3 (`:45,127`) | **CLEARED** | `terrain_donor_gen.gd:229-235`: `"plt2": 2222` at `:233`, `"k_ravine_big_stone_1": 8225` at `:234`; `decode_pattern_grid` gates on `F01_GRID_OFFSETS.has(name)` at `:592` | PowerShell `Select-String` for `F01_GRID_OFFSETS|plt2|8225` + Python targeted line read; both agree | None. Stale header comment `:51-55` lists only three offsets — cosmetic |
| V58-7 | I07 mine/ellipse centres add `W/2` twice | V58 §1 item 7 (`:49`) | **CLEARED** | `terrain_donor_gen.gd:1650-1661` `_mine_centre()` converts corner once (`W-24`/`24`, comment `:1656-1658` "no second W/2"); `_setup_mines:1488-1515` consumes cell centres; V86 §2 row 2 also re-read `_fill_ellipse:1446-1458` and `_start_to_cell:1434-1443` | PowerShell `Select-String` on `W / 2` hits (`:782` mask-centring only) + Python read of `:1484-1520,1646-1661` | None for this check. `[U]` residual `_to_scan` `+320` owner-map seed (V86 row 2) — labelled, separate ticket |
| V58-9 | I07 writes zero collision values | V58 §1 item 9 (`:51,263`) | **CLEARED** | `terrain_donor_gen.gd:1164` `data.set_collision(i, 0, tag)`, `:1167` sub-cell view, `:1173` tags 1–3; I06 API `terrain_donor_data.gd:279` `set_collision`, `:284` `collision_sub_index` | PowerShell `Select-String` + Python count of executable `set_collision`/`data.collision[` lines = 3 | None. Cliff tag stays `[U]` (`collision_tag_cliff=null`) — no value invented |
| V58-B/C | Cliff six-face table stubbed; shore `bRT` catch-all lost | V58 §Additional B `:308`, C `:318` | **CLEARED** | `terrain_donor_gen.gd:1216-1241` `_shore_tile_name`: 7 literal windows, `sname := "bRT"` as unguarded else at `:1221`, mapping `:1238-1241`; `:1262-1292` `_cliff_tile_name`: six PRE windows `:1269-1278`, mapping `:1279-1284`, live `|h|` overrides `:1286-1291`, `NO +180` at `:1267` | Python full-function re-read of both functions; PowerShell `Select-String` on `bRT`/`NO +180` agrees | None |
| V61 (a–f) | Four hard API breaks + shader path + seam | V61 §1 (`:55-68`); V48 | **CLEARED** (static, current lines drifted) | Composer `terrain_donor_world.gd:220-223` `gen_params: Dictionary` + `_call_adapt(_gen,"generate",[_data,gen_params])`; `:235-236` `to_live()`; `:253` `ptarget.call("build", _data, stamps, {"terrain":_mesh})`; callees `terrain_donor_gen.gd:438` `generate(data: C3TerrainData, p: Dictionary={})`, `terrain_donor_props.gd:211` `build(Object,Array,Dictionary)`; test `t_terrain_donor.gd:351` `_call_hook(g,["generate"],[data,settings])`, `:43` canonical shader | PowerShell `Select-String` of all six sites + Python targeted re-read; both agree on current line numbers | None for API shape. `[U]` Godot parse and stream assertions (`gen_applied` ≠ valid data) remain COORD's |
| Seam | Backend default must stay `legacy`; both guard sites intact | V61 §2(f); V76 §2 row 8; V86 row 14 | **CLEARED** | `main.gd:125 var terrain_backend := "legacy"`, `:189` `cfg.text("features.terrain.backend","legacy")`, guards `:593-594` and `:1112-1113`; `world3d.gd:118,144,145,220-224,624,645,707` | PowerShell `Select-String` + Python line read; both agree | None. Never re-apply the seam; keep `legacy` until red gates pass |
| Backups | `.bak-COORD-I11` SHA-exact vs V11 baselines | V11 E1/E2; V76 §2 row 8; V95 item 5 | **CLEARED** | `Get-FileHash`: `main.gd.bak-COORD-I11 = 3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8`; `world3d.gd.bak-COORD-I11 = 44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` (current seam files `FA9D93ED…` / `EEC6560A…`, as at V61/V65) | PowerShell `Get-FileHash` + Python `os.path.exists`; V95 item 5 adds independent `certutil` agreement | None. Re-verify SHA before any rollback |
| `app/**` + freeze set | `app/` byte-untouched; legacy freeze set unchanged | CHARTER §1/§4; V76 §2 row 9; V95 item 4 | **CLEARED** | `git status --short -- app/` → 0 lines; `git diff --exit-code -- app/` → exit 0; freeze set `game.gd world3d_terrain.gd world3d_relief.gd terrain_tileindex.gdshader project.godot` diff → exit 0 | PowerShell git read commands (both exits 0) + Python absence check of `app/**` paths; V95 `git diff --name-only` lists no `app/` | None. Re-run at gate 0 |
| Ack plan | 575/582/585 unacknowledged ⇒ `assert_clean` DIRTY | V76 §2 row 10 / §3; V42 §4.2:112-130; V86 row 16 | **OPEN** (plan landed, **execution NOT_RUN**) | `variant3d/.godot_queue/status.json`: exactly 41 rows in `FAILURE_STATUSES={"timed-out","error","skipped"}` (`assert_clean.py:42`), 38 acknowledged, **3 unacked = 575 timed-out, 582 skipped, 585 timed-out**; no `acknowledged`/`ack_reason` keys on those rows; `V42:128-130` supplies verbatim evidence-backed `ack <ticket> --reason "<text>"`; spool settled `counter=607`, `now_serving=607`, `jobs/`=0, `godot.lock` absent; all three result JSONs present | Python `json.load` with the exact `assert_clean.py:42` status set → 41/38/3 and ticket list `(575,582,585)`; independent key probe → no ack keys; PowerShell/Python spool census agree | **COORD**: execute three acks at A′-0, then plain `assert_clean.py --json`; accept only `verdict=CLEAN`, `reasons=[]`. Never `--ignore-history`, deletion, `reset`/`doctor`/`unwedge` |
| 320² | I12 determinism omits the hard 320² size | V86 row 18; V21 D-2; V38 F-V38-04 | **OPEN** | `t_terrain_donor.gd:60 const SIZES := [64, 240]`, `:61 const RUN_320_OPTIONAL := false`; `:396-398` appends 320 only under the flag; `DONOR_SIZES :74` contains 320 but is only a labelled donor-size table | PowerShell `Select-String` on `SIZES|RUN_320_OPTIONAL|320` + Python targeted line read; both agree | **I12 owner / COORD**: add 320 to `SIZES` or attach a COORD-signed waiver. Do not relabel a hard gate optional |
| Doc drift (non-blocking) | Stale board/handoff counts and report files | V76 §3 note; V86 row 13 | **OPEN** (documentation only) | `SWARM_BOARD.md:286-296` still says spec README PENDING / wrong report count while `spec/README.md:12-14,23-38` marks §00–§14 READY; `HANDOFF.md:46,70,77` still says "no `atlas/` tier / 780 JSONs" though five tiers now exist; V73/V74/V75 report files absent (edits landed) | Fresh read of the three docs vs the live spec README and asset census | **COORD / V73–V75 owners**: refresh last; no gate evidence changes |

## 3. What changed since the named reports (point-in-time, live tree)

- **V86** was NO-GO with 7 ordered blockers. Three of its OPEN rows are now
  overtaken by concurrent landings: the V42 spec path (B1-b) is repaired
  (`V42:27,177`), `V55_python_preflight.md` exists (B5), and the root
  `terrain_new/manifest.json` now exists with `schema=terrain_new/manifest/v1`.
- **V89** sealed 5,256 files / 358,196,527 B and called NO-GO for four asset
  reasons. The root-manifest reason is now cleared; the I09 feed mismatch,
  missing schema, season-layout conflict (`atlas/seasons/winter/*` absent while
  flat `atlas/seasons/tile_index_atlas_winter.*` is present — latent, no
  `set_season()` caller), and three missing X15 §2.4 atlas-manifest keys remain.
- **V90** reports 13/13 static PASS. Its stated context absences (V55, V83) are
  now false — both reports landed. The static seal itself is not a Godot parse.
- **V95** is current for B2/B3; its two anomalies (missing `.bak-I12`, CRLF
  warnings) are unchanged and non-blocking.
- **V83**'s single LIVE defect is not observable in current generated JSON, but
  the source emit sites still interpolate the resolved root; a regeneration
  could reintroduce it.

## 4. Final verdict and exact ordered blockers

> **NO-GO — do not run the V42 gate packet unchanged.** V96 ran no gate, no
> runner subcommand, no Godot job and no capture. `parity.claim = NONE`,
> `parity.status = UNVERIFIED`; no donor GPU A/B frame exists, so no tier above
> 2 exists and no visual claim is made. The blockers below are prerequisite
> defects, not a claim that any gate would fail if run.

Clear them **in this exact order**; none requires weakening an assertion,
lowering a threshold, deleting a failure or inventing a donor value:

1. **Execute the three acks** `575`, `582`, `585` with the verbatim V06/V42
   evidence-backed reasons (`V42_gate_commands.md:128-130`), then plain
   `python variant3d\tools\assert_clean.py --json`. Accept only `verdict=CLEAN`,
   `reasons=[]`. Do **not** use `--ignore-history`, delete result JSONs, or
   hand-edit `status.json`. *(Ack-plan row)*
2. **Close the I09 object-feed gap (P0):** choose one canonical path and one
   `_try_feed()`-accepted record shape, make
   `patterns/pattern_lib_index.json` exist (or repoint the single consumer at
   `lib/` with COORD ratification), and assert `feed_source` under
   `terrain_new/**` with `fallback_used=false`. The present 55.8 MB `lib/`
   index is at the writer's default path and its `generator_families` shape is
   not a valid props feed. *(B4-lib)*
3. **Land `schemas/v1.schema.json`** or explicitly retire G11 with COORD
   sign-off. *(B4-schema)*
4. **Resolve 320²:** add `320` to `SIZES` in `t_terrain_donor.gd:60` or attach a
   COORD-signed waiver to V21 D-2. Keep all thresholds intact. *(320² row)*
5. **Re-run and record the real Python preflight** at A′-1 (V42 §4.3
   `python -m py_compile …` on the six tools) against the **current** tree;
   V55's exit codes are valid for its own source hashes, not for today's post-
   V86 tree. *(B5 row)*
6. **Freeze, re-hash and re-census immediately before the packet:** re-run the
   V48 greps, the V33/V44/V83 forbidden scan, the V61 six-pair read,
   `git diff --exit-code -- app/` and the freeze-set diff, both seam-file/
   backup SHA checks, and the two asset censuses (the pack is still being
   written and is 0-files-tracked). Re-scan generated JSON for absolute donor
   paths after any regeneration. *(V61, seam, app, V83, B4 rows)*
7. **Refresh stale docs last:** `SWARM_BOARD.md:286-296`, `HANDOFF.md:46,70,77`,
   and file or explicitly retire the V73/V74/V75 report files. Non-blocking;
   no gate evidence changes. *(Doc-drift row)*

Only after 1–6 are satisfied may COORD run the packet in order
`A′-0 → A′-3 → D-0 → D-6`, one Godot at a time, with fresh result JSONs whose
mtimes follow job START. Keep `terrain_backend` at `legacy` until D-1/D-3 and
the red gates pass. **No donor-parity claim at any point** — parity remains
`UNVERIFIED` / `PORT APPROXIMATION` (CHARTER.md:43-44,125).

## 5. Five-line summary

1. **NO-GO.** B1/B2/B3 are statically CLEARED; V58's five I07 findings, V61's
   six API pairs, seam/backups/app and V83 hygiene are CLEARED in current bytes.
2. **B4 asset tiers:** `atlas/`, `masks/` and the X15-conformant root
   `manifest.json` are now PRESENT; `lib/pattern_lib_index.json` is present but
   at the wrong path/shape for I09, and `schemas/v1.schema.json` is absent —
   both OPEN.
3. **B5:** `V55_python_preflight.md` landed with all six exit codes 0; COORD
   must still re-run `py_compile` at A′-1 on the post-V86 tree.
4. **OPEN gates:** the 575/582/585 acks are still unexecuted (41 failure rows /
   38 acked / 3 unacked) and I12's 320² size is still optional — exact ordered
   blockers in §4.
5. **No gate, no parity.** Every verdict above is a static/filesystem
   prerequisite check; no Godot process, runner subcommand, capture, donor A/B
   frame or green result was produced by V96.

---

*End of V96 report. Exactly one repository file written (this report). Read-only;
no source, shader, asset, test, manifest, config, backup, queue, app/, git or Godot
state changed. No gate result and no donor-parity claim asserted.*
