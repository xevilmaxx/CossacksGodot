---
id: G13
ticket: TERRAIN-SWARM-WAVE-G / G13 (read-only audit)
title: "Backup provenance + disjoint-ownership audit of the six B edits and COORD's test fix"
owner: G13 (read-only — no code edits, no runner, this report only)
date: 2026-11-25
status: COMPLETE__NO_CODE_EDIT__NO_RUNNER
reports_read:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B05_selection_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B06_ghost_impl.md
labels: [observed, derived, UNVERIFIED]
---

# G13 — backup / ownership audit

## 0. Verdict (OBSERVED unless labelled otherwise)

- **All six `.bak-B0X` exist** under `inbox/backup/` and each is a byte-identical copy of
  the pre-edit `HEAD` blob of its owned source file.
- **Every stated provenance datum matches**: SHA-256 for B01/B02/B05; byte length for
  B03/B04/B06 (those three reports state no SHA).
- **Five of six B-owned source files are single-owner.** `input_controller.gd` (B05) is
  the one documented exception: COORD added two parse fixes after B05 landed. The
  cross-touch is acknowledged in `WAVE_G_CHARTER.md:22` and both lines are present at the
  exact cited positions (`:621`, `:876`).
- **`variant3d/tests/t_select_rect.gd` was changed by COORD only** — one hunk, the
  `:525` expectation fix. B05 explicitly did not touch any test file. Both
  `expected_pre_fix_failure` markers remain; no assertion was weakened, deleted or flipped.
- **One unowned working-tree change flagged**: `variant3d/selftest.json` (generated gate
  artifact, no B report claims it). It is not a B-file cross-touch; it belongs to the
  runner/gate owner (G04/COORD) and should be tracked by G12 runner hygiene.

No code, config, test or runner state was modified by this ticket.

## 1. Backup existence + provenance (OBSERVED)

SHA-256 and byte length computed with `Get-FileHash -Algorithm SHA256` / `Get-Item.Length`
on the files as they sit on disk. `pre-edit = HEAD` column is an *additional* check:
`git hash-object --path=<src> <backup>` compared with `git rev-parse HEAD:<src>`. All six
match, i.e. each backup is precisely the committed pre-edit file (line-ending filters
applied identically), not a hand-edited or post-edit snapshot.

| Ticket | Backup (`inbox/backup/`) | Size (B) | SHA-256 (actual) | Stated in B report | Match | Blob == HEAD |
|---|---|---:|---|---|---|---|
| B01 | `terrain_tileindex.gdshader.bak-B01` | 29,464 | `98671F38946EEF0D23AB1DB49DD4EE9CF1530DD54A3F700D16E6B7CFD5CC6034` | SHA `98671F…6034` (B01 front-matter :9) | **YES** | **YES** (`984e75dc…`) |
| B02 | `tile_atlas_loader.gd.bak-B02` | 17,986 | `9B82A48DF4F8A7DD6FF6AD1C99DBC6A57AE1C374603AFCC243128643C5F23978` | SHA `9B82A4…978` (B02 §8 :230-232) | **YES** | **YES** (`c15d0a7a…`) |
| B03 | `game.gd.bak-B03` | 238,546 | `0E46047B7B3CFC0D97A047C2B7BD7FD463B3F4000A54D8C316478AD352E3E7DF` | size 238,546 B (B03 §1 :44-45); **no SHA stated** | **YES (size)** | **YES** (`1688b704…`) |
| B04 | `world3d_terrain.gd.bak-B04` | 83,687 | `983DA45F2F72F262475917D212798F5C2176AB3B31CDE719F364538D15EFB04E` | size 83,687 B (B04 §0 :25-26); **no SHA stated** | **YES (size)** | **YES** (`06e48cbb…`) |
| B05 | `input_controller.gd.bak-B05` | 60,616 | `D78AFF5205DD0F350661C31AF41E65256D13987C6C90E8341E25A02A30011020` | SRC = BAK `D78AFF…020` at copy time (B05 §0 :29-31) | **YES** | **YES** (`ea1d02ff…`) |
| B06 | `world3d_fx.gd.bak-B06` | 67,530 | `AAD1F1325444372CFF62B9F85F41FFEEA23C3B46F731908C25F663D6FE35BDD1` | size 67,530 B (B06 §2 :55); **no SHA stated** | **YES (size)** | **YES** (`2ad6daa4…`) |

Cross-check against `git diff` index headers: B02 `index c15d0a7a…`, B05 `index ea1d02ff…`,
B06 `index 2ad6daa4…` — all equal the corresponding backup/HEAD blob prefix. B03/B04/B01
diffs carry no contradicting header. No backup is missing, duplicated under a wrong
ticket id, or taken after the edit.

**Derived [D]:** "backup before edit" is corroborated twice over — the report's own
claim plus the byte-for-byte equality with `HEAD`. There is no evidence of a
post-edit backup being substituted.

## 2. Working-tree ownership (OBSERVED diff / DERIVED attribution)

`git status --short` shows these modified tracked files. Attribution is from the report
front-matter (`file_owned` / `files_owned_edited` / `scope`) plus owner tags embedded in
each diff hunk.

| Modified file | Owner(s) | Evidence | Single owner? |
|---|---|---|---|
| `variant3d/shaders/terrain_tileindex.gdshader` | **B01** only | B01 front-matter `file_owned`; diff tags only `B01` / `A06-F2` follow-ups by B01 | YES |
| `variant3d/scripts/tile_atlas_loader.gd` | **B02** only | B02 front-matter; diff tags `B02` (mentions B01's concurrent hint in comments only) | YES |
| `variant3d/assets/terrain/atlas/tile_index_atlas.png.import` | **B02** only | B02 front-matter + §3 diff | YES |
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import` | **B02** only | B02 front-matter + §3 diff | YES |
| `variant3d/scripts/game.gd` | **B03** only | B03 front-matter; diff tags `B03-P1/P2/P3` only | YES |
| `variant3d/scripts/world3d_terrain.gd` | **B04** only | B04 front-matter; diff tags `B04` only (B03 referenced in a comment as separate owner) | YES |
| `variant3d/scripts/world3d_fx.gd` | **B06** only | B06 front-matter; diff tags `B06` only | YES |
| `variant3d/scripts/input_controller.gd` | **B05 + COORD** | B05 front-matter; COORD's two post-B05 parse fixes | **NO — documented cross-touch** |
| `variant3d/tests/t_select_rect.gd` | **COORD** only | `WAVE_G_CHARTER.md:25`; B05 §4.3/§5.1 explicitly disclaims test edits | YES |
| `variant3d/selftest.json` | **none claimed** | generated gate artifact; no B/G report claims it | **NO — unowned artifact** |

Untracked items: `docs/terrain_swarm_2026-11-25/` (all reports), the six backups, and
`variant3d/tools/terrain_ab_metric.py` (created by B01, per B01 §7). None is a cross-touch.

### 2.1 Documented cross-touch on B05's file (OBSERVED)

`WAVE_G_CHARTER.md:22` states: *"COORD fixed two parse errors after B05 (`:621` typed
`dst: Viewport`, `:876` `KEY_CTRL`)."* Both are present in the current tree at exactly
those lines:

```
621: var dst: Viewport = camera.get_viewport()
876: var ctrl_held := Input.is_key_pressed(KEY_CTRL)
```

Both sit inside B05's large diff, so `input_controller.gd` is the only B-owned file with
two writers. This is an **accepted, charter-documented exception**, not an unauthorized
edit. Corroboration: B05 §0 recorded its post-edit SHA as
`7D8732C423D21BDE39B40D1CC6F589ACD60ABC5ADB742B81B0CF58B60F4D2426`; current worktree
SHA is `9212F22A8E0CCA24521AC310E3AFDA9BEF07492D37CE17D1C87ACFA514F91B4F`. Line counts
still match B05's report exactly (backup 1,473 → current 1,639), so the delta is the two
COORD fixes, not a stray rewrite. **[D]** No further COORD/B05 ambiguity found.

### 2.2 Unowned `selftest.json` (OBSERVED / flagged)

Diff is a regenerated selftest result (gold `245.02→241.70`, wood `712→768`,
shots `73→51`, `sim_seconds` and every `wall_ms` changed, node `1015→1019`). No B
report and no Wave G report mentions this file; it is runner output, consistent with the
wave's gate re-run activity. It is **not** an edit to any B-owned source file, so it is
not a B cross-touch — but it has no recorded owner in the current report set. Recommend
G04 (sole runner owner) / G12 (runner hygiene) account for it. **[U]** Which specific job
generated it cannot be established read-only from the diff alone.

## 3. `t_select_rect.gd` — COORD-only change and retained markers (OBSERVED)

`git diff -- variant3d/tests/t_select_rect.gd` has **exactly one hunk**
(`@@ -522,7 +522,11 @@`), changing the single wrong expectation:

```gdscript
-	var expected := Rect2(_p0, _p1).abs()
+	var expected := Rect2(_p0, _p1 - _p0).abs()
```

- **COORD only.** `WAVE_G_CHARTER.md:25` attributes the `:525` fix to COORD. B05 §4.3
  says *"No test file was touched by B05"* and §5.1 hands the fix to the TEST owner. No
  B01–B06 report claims a test edit, and no other Wave G agent has authored a change to
  this file (G01's capture atom is a *new* file, G03 is read-only). The inserted comment
  inside the hunk begins `# B05:` — that is COORD citing B05's finding, **not** evidence
  of a B05 edit; flagging it here so it is not misread as a cross-touch.
- **No test weakening.** The assertion is corrected, not removed or relaxed; the
  `Rect2(position, size)` semantics fix makes the green result truthful. No threshold or
  marker was flipped.
- **Two `expected_pre_fix_failure` markers remain intact.** The single source marker is
  `check(..., true)` at `t_select_rect.gd:543` inside `_assert_overlay()`, which feeds the
  two call sites at `:615` (`overlay_rect_during_drag`) and `:616`
  (`overlay_hidden_after_release`). The recorded results file
  `variant3d/tests/results/t_select_rect.json` has **exactly two** checks with
  `"expected_pre_fix_failure": true` — those same two names. No marker was deleted or
  changed to `false`.

## 4. Cross-touch flags summary

| # | Flag | Severity | Detail |
|---:|---|---|---|
| 1 | COORD on B05's `input_controller.gd` (`:621`, `:876`) | **documented / accepted** | Only multi-writer B file; charter-sanctioned parse fixes. No action unless COORD wants the two lines re-attributed in a later integration note. |
| 2 | `selftest.json` changed with no owning report | **low / hygiene** | Generated artifact, not a B source file. Route to G04/G12. |
| 3 | `# B05:` comment on COORD's `:525` test fix | **informational** | Comment text misattributes authorship; code ownership is COORD per charter. |
| — | No cross-touch found in `game.gd`, `tile_atlas_loader.gd`, the two `.import` files, `world3d_terrain.gd`, `world3d_fx.gd`, or the shader | **clean** | Diff owner tags match the single report front-matter owner in every case. |

## 5. Paste-ready PowerShell re-check (read-only, run from repo root)

```powershell
$ErrorActionPreference = 'Stop'
$expected = @(
  @{T='B01';Bak='inbox/backup/terrain_tileindex.gdshader.bak-B01';Src='variant3d/shaders/terrain_tileindex.gdshader';Sha='98671F38946EEF0D23AB1DB49DD4EE9CF1530DD54A3F700D16E6B7CFD5CC6034';Len=0},
  @{T='B02';Bak='inbox/backup/tile_atlas_loader.gd.bak-B02';Src='variant3d/scripts/tile_atlas_loader.gd';Sha='9B82A48DF4F8A7DD6FF6AD1C99DBC6A57AE1C374603AFCC243128643C5F23978';Len=0},
  @{T='B03';Bak='inbox/backup/game.gd.bak-B03';Src='variant3d/scripts/game.gd';Sha='';Len=238546},
  @{T='B04';Bak='inbox/backup/world3d_terrain.gd.bak-B04';Src='variant3d/scripts/world3d_terrain.gd';Sha='';Len=83687},
  @{T='B05';Bak='inbox/backup/input_controller.gd.bak-B05';Src='variant3d/scripts/input_controller.gd';Sha='D78AFF5205DD0F350661C31AF41E65256D13987C6C90E8341E25A02A30011020';Len=0},
  @{T='B06';Bak='inbox/backup/world3d_fx.gd.bak-B06';Src='variant3d/scripts/world3d_fx.gd';Sha='';Len=67530}
)
foreach ($e in $expected) {
  $exists = Test-Path $e.Bak
  $sha = if ($exists) { (Get-FileHash -Algorithm SHA256 $e.Bak).Hash } else { '' }
  $len = if ($exists) { (Get-Item $e.Bak).Length } else { 0 }
  $shaOk = if ($e.Sha) { $sha -eq $e.Sha } else { 'n/a' }
  $lenOk = if ($e.Len) { $len -eq $e.Len } else { 'n/a' }
  $bakBlob = if ($exists) { (git hash-object --path=$e.Src $e.Bak).Trim() } else { '' }
  $headBlob = (git rev-parse "HEAD:$($e.Src)").Trim()
  '{0}: exists={1} shaMatch={2} sizeMatch={3} preEditEqualsHEAD={4}' -f $e.T,$exists,$shaOk,$lenOk,($bakBlob -eq $headBlob)
}
$d = git diff --unified=0 -- variant3d/tests/t_select_rect.gd
$hunks = @($d | Where-Object { $_ -like '@@*' }).Count
$fix = @($d | Where-Object { $_ -like '+*Rect2(_p0, _p1 - _p0).abs()*' }).Count
$gdMarkers = @(Select-String -Path 'variant3d/tests/t_select_rect.gd' -Pattern 'str\(expected\)\], true\)').Count
$jsonMarkers = @(((Get-Content 'variant3d/tests/results/t_select_rect.json' -Raw | ConvertFrom-Json).checks) | Where-Object { $_.expected_pre_fix_failure -eq $true }).Count
"T_SELECT_RECT: hunks=$hunks fixLines=$fix markersInGd=$gdMarkers markersInJson=$jsonMarkers"
Select-String -Path 'variant3d/scripts/input_controller.gd' -Pattern 'var dst: Viewport = camera.get_viewport\(\)|KEY_CTRL' | ForEach-Object { "COORD_CROSS_TOUCH line {0}: {1}" -f $_.LineNumber, $_.Line.Trim() }
```

Expected output: six `exists=True` lines with `shaMatch=True` (B01/B02/B05),
`sizeMatch=True` (B03/B04/B06), all `preEditEqualsHEAD=True`; then
`T_SELECT_RECT: hunks=1 fixLines=1 markersInGd=1 markersInJson=2`; then the two
`COORD_CROSS_TOUCH` lines at 621 and 876.

## 6. Open questions (UNVERIFIED)

1. Which runner job regenerated `variant3d/selftest.json` — not derivable read-only;
   hand to G04/G12.
2. Whether COORD intends to annotate the two `input_controller.gd` parse fixes with a
   COORD tag in a future integration pass (currently untagged inside B05's hunks).
3. No donor/GPU claim was evaluated here; this audit is provenance and ownership only.

*End of G13 report. Read-only ticket: no code, config, test or runner state changed; only this report was written.*
