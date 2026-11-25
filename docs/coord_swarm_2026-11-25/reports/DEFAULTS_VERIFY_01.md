---
id: DEFAULTS-VERIFY-01
owner: DEFAULTS-VERIFY-01 subagent (read-only verification worker)
date: 2026-11-25
status: complete
task: Verify owner's requested skirmish defaults after all concurrent edits
scope: static verification of current files + existing artifacts only; no code edits, no runner jobs
verdict: |
  All seven requested settings resolve to the owner's requested values on both paths.
  The interactive skirmish path and the menu-skipping path AGREE in effect.
  Raw `gameplay.map_type: land` is still present in variant3d/config.json:73, but it is
  NOT what a menu-skipping run applies: config.gd's built-in DEFAULT seeds
  gameplay.terrain_type = "mediterranean" and load_all() merges config.json over that
  DEFAULT, so config.gd:545 reads "mediterranean" first. CFG-02's and QA-AUDIT F-05's
  refutation of CFG-01's "superseded" note is therefore itself incorrect.
labels: |
  [OBS] observed in a file/artifact; [DER] derived by reading code semantics;
  [INF] inferred from indirect evidence; [UNVERIFIED] no second source available.
---

# DEFAULTS-VERIFY-01 — post-swarm skirmish defaults verification

## Sources

All paths relative to `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.

| Source | What it supplies | Label |
| --- | --- | --- |
| `reports/CFG_01_skirmish_defaults.md` (CFG-01) | before/after values, value tables, donor citations, tickets 312/313/314 | [OBS] |
| `reports/CFG_02_no_menu_defaults.md` (CFG-02) | no-menu key map, 320→240 attempt + revert, tickets 315/317/319/322/325, its `map_type` claim | [OBS] |
| `reports/MAP_SMALL_01.md` / `reports/MAP_SMALL_01_report.md` | **NOT LANDED** (no file found; `PROGRESS.md:101-103`, `QA_AUDIT_01:101` confirm unlanded) | [OBS] |
| `variant3d/scripts/menu.gd:21-29,55,60,64,70-71,78,726,925-947,958-965` | interactive defaults and `_emit_start()` payload | [OBS] |
| `variant3d/scripts/config.gd:46-84,88-141,262,273-301,354-384,404-412,489-571,604-610` | built-in DEFAULT, merge, `value/text`, `apply()` | [OBS] |
| `variant3d/config.json:22,41-43,71-74` | no-menu overlay file | [OBS] |
| `variant3d/scripts/data.gd:55,176-190,198-204,227-228,245-259,293-326,328-336` | statics, nation/shape/relief/season tables | [OBS] |
| `variant3d/scripts/main.gd:176-177,231,253-256,270-315,364-367` | load/apply vs `_apply_menu_cfg()` path split | [OBS] |
| `variant3d/scripts/game.gd:290-294,387-388` and `variant3d/scripts/uitest.gd:106-113` | FFA team fallback; uitest's **explicit** tur/rus/land override | [OBS] |
| `variant3d/selftest.json` (worktree), `variant3d/uitest.json` | existing artifacts: selftest `passed:false`, 28/29 (failed `build`); uitest `passed:true`, 17/17 | [OBS] |
| `reports/QA_AUDIT_01_implementation_claims.md:41,80-85,97-103,125-126` | F-05 refutation of CFG-01 and MAP-SMALL-01 note | [OBS] |
| `PROGRESS.md:67-71,97-103,181,188-189`, `SWARM_BOARD.md` (Batch D) | CFG-01/02 and MAP-SMALL-01 ownership/state | [OBS] |
| `git log/show`: `f9dd8d16` (2026-11-25 10:08), `90091434`; `git status --short` | commit attribution; four default files clean in worktree | [OBS] |
| `inbox/backup/config.json.bak-MAPSMALL01`, `.bak-CFG02`, `inbox/backup/config.gd.bak-CFG01`, `menu.gd.bak-CFG01` | pre-change baselines (both config backups = 320×320 / `land`) | [OBS] |
| Static Python simulation of `_copy(DEFAULT)` + `_merge(config.json)` + `apply()` (read-only, no files written) | applied-value resolution | [DER] |

## Defaults table

Interactive = `menu.gd` variable defaults emitted by `_emit_start()` (`menu.gd:925-947`) and applied by `main.gd:270-367`. No-menu = `config.json` overlay (via `main.gd:176-177` → `config.gd:apply()`). Applied = the effective `Data.*` value after `apply()` on a menu-skipping run.

| Setting | Interactive default (`menu.gd`) | No-menu default (`config.json`) | Applied default (`config.gd`) | Donor citation | Status |
| --- | --- | --- | --- | --- | --- |
| Nations (P0/P1) | `rus` vs `bav` (`:21-22`; roster fill `:556-571`; emitted `:925`, `:960-963`) [OBS] | `rus` vs `bav` (`:71-72`) [OBS] | `rus` vs `bav` (`config.gd:121-122`, `:550-551`, `:566`) [OBS+DER] | `data.gd:245-259` `NATIONS` (country.script sids: `rus` Russia `:250`, `bav` Bavaria `:256`); `data.gd:177` `PLAYER_NATIONS` | **MATCH** |
| Map size | `240` Tiny (`:60`; dropdown `:726`; emitted `:942`,`:947`) [OBS] | `240`×`240` (`:41-42`) [OBS] | `240`×`240` (`config.gd:118-119`, `:523-524`) [OBS+DER] | Port dropdown `menu.gd:726` (240/320/400/480); donor literal Tiny = 256 per `donewgame.inc:42-49` cited in CFG-01:44 and `DEC_06:455` — **port value 240 diverges from donor literal 256 by deliberate choice** | **MATCH** (port-internal; donor gap noted) |
| Map type / shape | `mediterranean` (`:55` `map_type`, `:64` `terrain_type`; emitted both `:927`,`:945`) [OBS] | **`land`** (`:73`); no `terrain_type` key [OBS] | **`mediterranean`** (`config.gd:545` reads `gameplay.terrain_type`), sourced from built-in `DEFAULT` (`:125`) [OBS+DER] | `data.gd:293-302` `MAP_TYPES` (generator.cfg `TerrainTypes`); `data.gd:315-326` `DONOR_MAP_SHAPES`, `coastal → mediterranean` at `:322` | **DIVERGE (raw key only); applied MATCH** |
| Relief | `low_mountains` (`:71`; emitted `:928`,`:945`; → sim `hills` via `main.gd:302-315`) [OBS] | no `relief` key [OBS] | `hills` (`config.gd:129`, `:548`; guard `:608-610` not triggered because merged `gp` has `relief`) [OBS+DER] | `data.gd:328-336` `DONOR_RELIEF` (gui.txt:449-460): `low_mountains` → `hills` at `:330`; sim tiers `data.gd:215-216` | **MATCH** |
| Fog of war | `"off"` (`:78`; emitted bool `:939`) [OBS] | `false` (`:22`) [OBS] | `false` (`config.gd:96`, `:498`; `data.gd:55`) [OBS] | No donor flag located; CFG-01 §"Fog of war" (`:61-70`) records "no fog key in menu", already off on every path — donor side **[UNVERIFIED]** | **MATCH** |
| Season | `summer` (`:70`; emitted `season` `:928` and `season_enum` `:936`) [OBS] | no `season` key [OBS] | `summer` (`config.gd:127`, `:546`; `data.gd:199`) [OBS+DER] | `data.gd:227-228` `SEASON_ENUM` summer=0 from `map.script:250`; `CONFIG_UI_01.md:36` | **MATCH** |
| Teams | `ffa` (`:24` `teams_mode`, `:29` `team_preset`), `players = 2` (`:28`); emitted `:926`,`:964` [OBS] | no `teams` key [OBS] | `Data.TEAMS = []` (`config.gd:570-571`) → per-slot `team = -1` FFA (`game.gd:290-294`, `:387-388`; `data.gd:178-190`) [OBS+DER] | Port contract `data.gd:178-190` ("2 players / free-for-all so existing tests hold"); direct donor citation **[UNVERIFIED]** in CFG-01/CFG-02 | **MATCH** |

### Double verification of every row (file read + second source)

- Nations: `menu.gd:21-22` + `data.gd:176-177`/`data.gd:250,256`; overlay `config.json:71-72` + applied `config.gd:550-551`. CFG-01:18-19 independently observed the same pair. [OBS]
- Map size: `menu.gd:60`/`:726` + `config.json:41-42` + `config.gd:118-119,523-524`; CFG-01:42-49 and CFG-02:66-67 record both 240 sources. [OBS]
- Map type: `config.json:73` (`land`) is second-checked against the read at `config.gd:545` and the DEFAULT at `config.gd:125`; absence of `terrain_type` in `config.json` is second-checked by the read-only parse and by `config.gd:605` (guard). Resolution `mediterranean` is second-checked against CFG-01:109,113 (runner artifact changed because " Mediterranean + hills" were selected on the no-menu path). [OBS+DER]
- Relief: `menu.gd:71` + `data.gd:330` (`low_mountains → hills`) + `config.gd:129,548`; CFG-01:22,57,85 and CFG-02:30,49 agree. [OBS]
- Fog: `menu.gd:78` + `config.json:22` + `config.gd:498` + `data.gd:55`; CFG-01:23,65,70 and CFG-02:31 independently observed off/false. [OBS]
- Season: `menu.gd:70` + `config.gd:127,546` + `data.gd:199,227-228`; `CONFIG_UI_01.md:36` and `SP_01_season_enum.md` corroborate summer=0. [OBS]
- Teams: `menu.gd:24,28-29` + `config.gd:570-571` + `data.gd:189-190` + `game.gd:294,388`. [OBS]
- Artifact caveat: `variant3d/uitest.json` step `menu_shell` says "skirmish setup **tur vs rus** applied" — this is NOT a default check; `uitest.gd:106` passes `{"nation0":"tur","nation1":"rus","map_type":"land"}` explicitly. `variant3d/selftest.json` records no `MAP_TYPE`/`RELIEF`/map-size field at all. Therefore artifacts corroborate that the paths execute, **not** the defaults; all default values rest on two independent *files* per row. [OBS]

## Explicit check: `map_type: land`, `terrain_type` read, and Mediterranean+hills on a menu-skipping run

1. **Is `map_type: land` still present?** **Yes — `variant3d/config.json:73`** [OBS]. `git status --short -- variant3d/config.json …` shows no worktree modification; HEAD contains the same line [OBS]. Both backups (`config.json.bak-CFG02`, `config.json.bak-MAPSMALL01`) also contain `land`, so it was never changed to Mediterranean in the final overlay [OBS].
2. **Is `terrain_type` actually read?** **Yes.** The CFG-02/Q&A line reference `config.gd:429` is stale; the current read is **`config.gd:545`**:
   `Data.MAP_TYPE = text("gameplay.terrain_type", text("gameplay.map_type", "mediterranean"))` [OBS].
   But `text()` (`config.gd:404-406`) calls `value()` (`:387-394`) against `data`, and `load_all()` starts from `_copy(DEFAULT)` (`:274`) then `_merge(base, _parse(config.json))` (`:280`); `_merge` (`:378-384`) merges dictionaries key by key. `DEFAULT.gameplay` contains `terrain_type: "mediterranean"` (`:125`) and `relief: "hills"` (`:129`) [OBS]. Since `config.json` has no `terrain_type`/`relief` keys (`:38-75`), the merged `data` retains both built-in values [DER]. Consequently the outer `text("gameplay.terrain_type", …)` succeeds with `"mediterranean"` and the inner fallback `"land"` is **evaluated but discarded** [DER]. The static simulation reproduced exactly: `MAP_W/H=240/240`, `MAP_TYPE=mediterranean`, `RELIEF=hills`, `BIOME=summer`, nations `rus/bav`, fog `False` [DER].
   - Verdict on the dispute: **CFG-01's "superseded by the new built-in terrain_type" note is CORRECT in effect; CFG-02:40-50 and QA_AUDIT F-05 (`:80-85`) are wrong** — they assumed `text(path, fallback)` probes only the JSON file, ignoring the DEFAULT merge [DER]. The `config.gd:605` guard CFG-02 mentions is indeed skipped, but that guard is a *later* donor-id resolution step and does not undo the value already assigned at `:545`. CFG-02's empirical isolation (tickets 317/319: `land` vs `mediterranean` gave identical failures) proves only that map type was not the selftest failure cause; it does not prove which value was applied [DER].
3. **Does the current default yield Mediterranean + hills on a menu-skipping run?** **Yes, in effect** [DER]: shape `mediterranean` (`config.gd:545` via DEFAULT `:125`), relief `hills` (`:548` via DEFAULT `:129`), with the 240×240 size from `config.json:41-42`. Note that this is a code-semantics derivation plus artifact corroboration (CFG-01:109), **not** a fresh runtime dump: no `--dump-config` artifact from the current tree was found, so the runtime value is [DER] rather than freshly [OBS]. The raw `land` key is a latent trap, not a present runtime divergence.

## Concurrent-edit attribution (git)

| File | Worktree state | Last change | Attribution |
| --- | --- | --- | --- |
| `variant3d/config.json` | clean | `f9dd8d16` (2026-11-25 10:08:02) changed `map_width_tiles`/`map_height_tiles` **320 → 240**; `map_type: land` untouched; no `terrain_type`/`relief` added | **MAP-SMALL-01** [INF] — its owned files are `selftest.gd` + `config.json` (`SWARM_BOARD.md` Batch D), the same commit carries the `_spot()` rewrite whose comment literally says `MAP-SMALL-01`, its backup `config.json.bak-MAPSMALL01` holds the pre-change 320/`land`, and `PROGRESS.md:101-103` says `config.json` is "committed at 240² without a landed MAP-SMALL-01 report". CFG-01 explicitly did not own this file (`:113`); CFG-02 explicitly reverted it to 320 (`:124-125`). |
| `variant3d/scripts/config.gd` | clean | `f9dd8d16` carried CFG-01's value edits; later `0628b3cf` shifted line numbers (e.g. 429 → 545) by adding `FEATURES_DEFAULTS` (CONFIG-CORE-01) | CFG-01 [OBS], plus later CONFIG-CORE-01/CONFIG-WIRE work [OBS] |
| `variant3d/scripts/menu.gd` | clean | `f9dd8d16` carried CFG-01's 4 values; later `0628b3cf` added CONFIG-UI-01 season/weather/roster lines | CFG-01 [OBS], CONFIG-UI-01 [OBS] |
| `variant3d/scripts/data.gd` | clean | `b1332b91` (2026-11-25 10:31) | not a defaults change for this task [OBS] |
| `variant3d/selftest.json` | modified (32 lines; numeric-only, 28/29) | runner output | concurrent jobs after CFG-02; not a hand edit [INF] |

## Divergences, ranked

1. **D1 — Raw `gameplay.map_type: land` vs interactive `mediterranean`** (`config.json:73`). Applied value is correct today, but the file is self-contradictory and has already produced two false audit conclusions (CFG-02, QA F-05). A future removal of `DEFAULT.gameplay.terrain_type`, or a `--config` overlay that clears it, would silently restore `land`. Severity: MEDIUM (latent + documentation contamination), not a current gameplay failure. [OBS+DER]
2. **D2 — MAP-SMALL-01 landed its code change but not its report/evidence.** `config.json` is committed at 240² via `f9dd8d16`, yet `MAP_SMALL_01*.md` is absent and the integrated selftest artifact is not green (`variant3d/selftest.json`: `passed:false`, 28/29, failed `build`; `PROGRESS.md:100-103` reports HEAD 26/29 and worktree 28/29). The requested smaller default is present on both paths, but the gate is not proven after all merges. Severity: MEDIUM-HIGH process risk. [OBS+INF]
3. **D3 — Two landed reports assert the wrong resolution.** `CFG_02_no_menu_defaults.md:40-50,137-140` and `QA_AUDIT_01_implementation_claims.md:80-85,125-126` claim `land` is actually read and CFG-01's note refuted. They omit the DEFAULT merge at `config.gd:274-301`. Severity: MEDIUM (wrong guidance to future owners). [DER]
4. **D4 — Port Tiny 240 vs donor literal Tiny 256** (`menu.gd:726`, CFG-01:44-49, `DEC_06:455`). Accepted by CFG-01 to keep the dropdown value coherent; no action unless the owner requires donor-exact 256 (which would require an option-table change). Severity: LOW / accepted. [OBS]
5. **D5 — Artifacts do not encode defaults.** `uitest.json` uses an explicit `tur`/`rus`/`land` setup (`uitest.gd:106`); `selftest.json` has no shape/relief/size fields. No fresh `--dump-config` artifact was found, so the no-menu resolution cannot be shown from an artifact alone. Severity: LOW (verification gap). [OBS]

## Recommendation tickets (read-only — no code changed here)

- **REC-DEFAULTS-DOC-01** — Amend `CFG_02_no_menu_defaults.md:40-50` and `QA_AUDIT_01_implementation_claims.md:80-85` (F-05) to record that `text()` reads the merged `DEFAULT`+`config.json` data (`config.gd:274-301,387-406`), so `terrain_type: mediterranean` wins over raw `map_type: land`. Attach this report as evidence. Documentation-only; no gate needed.
- **REC-CFG-03** — If the owner wants the raw overlay self-consistent, assign `variant3d/config.json` to an owner and change `:73` `land → mediterranean` (value-only) or add `terrain_type: "mediterranean"`. This is **not required for current behaviour** and must be followed by both variant gates; note CFG-02 already showed value-only edits there can fail the selftest.
- **REC-MAPSMALL-DOC-02** — Require MAP-SMALL-01 to land `MAP_SMALL_01_report.md` citing commit `f9dd8d16`, the `_spot()` radius derivation (`selftest.gd:123-...`), and green selftest evidence at both 240² and 320²; otherwise revert `config.json` to 320² so the committed default matches the last green gate.
- **REC-GATE-03** — Re-run selftest + uitest + clean after all concurrent edits before claiming the integrated defaults are green. Current artifacts: selftest 28/29 (`build` false), uitest 17/17.
- **REC-DONOR-04** — Decide and record whether port Tiny stays 240 or becomes donor-literal 256; if 256, `menu.gd:726` option table must change too (outside default-value edits).
- **REC-ARTIFACT-05** — Capture a `--dump-config` artifact from a menu-skipping run and archive it with the defaults report, so applied `MAP_TYPE`/`RELIEF`/`MAP_W` become [OBS] rather than [DER].

## Open questions

1. `config.gd:296-301` merges `user://options.json` as a third layer. If that file exists on the owner's machine with `gameplay.terrain_type`/`relief`/map-size keys, it overrides the values above. This verification did not inspect the user data directory — **[UNVERIFIED]**.
2. MAP-SMALL-01 never landed; its stated goal was "prove 29/29 at both sizes". Only its code is in HEAD, with a non-green integrated selftest artifact — **[UNVERIFIED]** final proof.
3. Donor-side citations for fog-off and FFA teams were not located by CFG-01/CFG-02; only port-side evidence exists — **[UNVERIFIED]** donor claim.
4. Whether the owner wants the raw `land` key corrected for documentation clarity, given it is currently overridden — decision required.
5. Whether the four default files were intentionally committed in a combined `step` commit (`f9dd8d16`) rather than per-ticket commits — attribution of config.json is [INF] from ownership + backup + inline comment, not from a commit message.

## Summary

Against the owner's request — 2 nations Russia vs Bavaria, smaller map, Mediterranean-with-hills, no fog — **all seven settings resolve correctly on both the interactive and menu-skipping paths** as of the current tree [OBS+DER]. Nations `rus`/`bav`, size 240×240, shape `mediterranean`, relief `hills`, fog off, season `summer`, teams FFA/2 players.

The one raw mismatch is `variant3d/config.json:73` `map_type: land`: it is still present, but it is **not** what the no-menu run applies, because `config.gd:545` reads `gameplay.terrain_type` and the built-in `DEFAULT` (`:125`) supplies `mediterranean` through the merge at `:274-301`. CFG-02's refutation of CFG-01 (and QA-AUDIT F-05) is therefore itself refuted. The 240×240 overlay change is attributed to MAP-SMALL-01 via commit `f9dd8d16`, whose report never landed; the integrated selftest artifact remains non-green. No code was edited and no runner job was launched for this verification.
