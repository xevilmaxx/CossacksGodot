# Documentation consistency audit — agentX (2026-11-21)

Scope: documentation consistency only. Source docs audited:
`docs/guides/GUIDE1.md`, `GUIDE2.md`, `GUIDE3.md`, `docs/TERRAIN_GEN_RESEARCH.md`,
`reference/videos.md`. No code/config/MECHANICS/COMMANDS/README/GUIDE4 edits.
All line numbers below are **current file line numbers** measured on 2026-11-21,
not the guide's own (drifted) anchors.

Verdicts: **CONFIRMED** = matches code/asset · **STALE** = no longer true ·
**UNVERIFIABLE** = cannot check without a Godot run, an external source, or
another worker's owned file.

## 1. Claim spot-check table

| # | Source doc | Claim | Verified against | Verdict | Note |
|---|---|---|---|---|---|
| 1 | GUIDE1 L35 / GUIDE2 L26 / GUIDE3 L27 | Godot **4.7.2** on PATH / project features "4.4", `gl_compatibility` | `app/project.godot` (`config/features=PackedStringArray("4.4", "GL Compatibility")`, `renderer/...="gl_compatibility"`); `README.md:17,39` says "Godot 4.7" | UNVERIFIABLE / part-CONFIRMED | Project config confirms "4.4"/`gl_compatibility`; the precise binary patch `4.7.2` needs a `godot --version` run, which this task forbids. README (worker E) corroborates 4.7.x. Left unchanged. |
| 2 | GUIDE1 L36 / GUIDE2 L27 / GUIDE3 L28 | Blender 5.2 at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` | filesystem `Test-Path` → True | CONFIRMED | — |
| 3 | GUIDE1 L38 | "repo \| NOT git" | `git status --short` returns a full modified/untracked list | **STALE → FIXED** | Now a git repo. Edited to "Git repo (initialised after this guide was written; it was NOT git on 2026-11-18)". |
| 4 | GUIDE1 L24 | `reference/videos.md` has "14+ gameplay videos" | `reference/videos.md:11-27` (17 numbered entries) | CONFIRMED | Still true (17 ≥ 14). |
| 5 | GUIDE1 L64 | 92 static sprites | `app/assets/models/sprites/*.png` → 92 files | CONFIRMED | — |
| 6 | GUIDE1 L65 | 305 sounds | `app/assets/sounds/**/*.ogg` → 305 files (610 with `.import`) | CONFIRMED | — |
| 7 | GUIDE1 L55-57 / GUIDE2 L50-51 | mines 1.664/s, upkeep /625 | `app/scripts/data.gd:54` (`MINE_INCOME_PER_S := 13.0*32.0/250.0  # 1.664`), `:56` (`UPKEEP_DIVISOR := 625.0`) | CONFIRMED | — |
| 8 | GUIDE1 L86 | `archer.oss` is 146872 bytes | donor `C:\Games\Cossacks 3\data\actors\units\archer.oss` → 146872 bytes | CONFIRMED | — |
| 9 | GUIDE1 §3 world.gd L32 | `var anim_t` ambient clock | `app/scripts/world.gd:64` | STALE (anchor drift +32) | Not renumbered, per task. See §2. |
| 10 | GUIDE1 §3 world.gd L37 / L40 | `SPRITE_ALIAS` / `SPRITE_TINT` | `app/scripts/world.gd:81` / `:84` | STALE (anchor drift +44) | Not renumbered. |
| 11 | GUIDE1 §3 world.gd L83 / L119 / L122 / L132 | `_load_sprites` / `_sprite_frames` / `_sprite_for` / `_draw_sprite` | `app/scripts/world.gd:169` / `:208` / `:214` / `:483` | STALE (anchor drift +86…+351) | Not renumbered. Note `_draw_sprite` moved by ~351 lines. |
| 12 | GUIDE1 §3 game.gd L332 | `spawn()` entity dict | `app/scripts/game.gd:1229` | STALE (anchor drift +897) | Not renumbered. Largest single drift found. |
| 13 | GUIDE1 §3 game.gd L1072 / L1147 | `_kill()` / `_tick_unit()` | `app/scripts/game.gd:2538` / `:2789` | STALE (anchor drift +1466 / +1642) | Not renumbered. |
| 14 | GUIDE1 §3 game.gd L850 / L858 / L761 / L900 | `effective_speed` / `effective_damage` / `research` / `train_unit` | `app/scripts/game.gd:2178` / `:2186` / `:2019` / `:2301` | STALE (drift) | Not renumbered. |
| 15 | GUIDE1 §3 game.gd L613 / L687 / L721 | `squad_form` / `squad_set_formation` / `formation_targets` | `app/scripts/game.gd:1849` / `:1928` / `:1965` | STALE (drift) | Not renumbered. |
| 16 | GUIDE1 §3 data.gd L117 / L428 | `NATIONS` / `apply_damage` | `app/scripts/data.gd:167` / `:821` | STALE (drift +50 / +393) | Not renumbered. P-06 (board) concerns `apply_damage` indexing — see §4. |
| 17 | GUIDE1 L9 (dated STATUS) | "self-test 21/21" | 21/21 was true at 2026-11-18 authoring; current gate is 28/28 (`GUIDE3.md:57`, `:2351`) | CONFIRMED (as of date) | Dated executor STATUS, not changed. Superseded by G15. |
| 18 | GUIDE2 L67 | "hud.gd ~line 322" research-button loop | `app/scripts/hud.gd:459-470` (`for uid in Data.UPGRADES ...`) | STALE (anchor drift +137) | Not renumbered. |
| 19 | GUIDE2 L65 | "selftest.gd **21 steps**" | `app/selftest.json` → 29 steps, 28 passing (farm_cap fails, board P-04) | **STALE → FIXED** | Edited to "29 steps (28-pass gate; 21 at GUIDE2 authoring)". |
| 20 | GUIDE2 L1039 (STATUS, 2026-11-18/19) | "selftest 21/21, uitest 11/11" | accurate at authoring; `app/uitest.json` → 17 steps now; G15 gate 28/28 + 17/17 | CONFIRMED (as of date) | Dated executor STATUS, not changed. Superseded by G15. |
| 21 | GUIDE2 S1 L93-94 | `cen` farm 200→100, `bar` farm 75→150 | `app/scripts/data.gd:649` (`"farm": 100`), `:654` (`"farm": 150`) | CONFIRMED | — |
| 22 | GUIDE2 S1 L101-104, L112-118 | map 160→320 in config defaults and shipped config | `app/scripts/config.gd:46,47,366,367` = 320; `app/config.json` = 320/320 | CONFIRMED | — |
| 23 | GUIDE2 S1 L96-97 | `AI_MAX_PEASANTS` 14→40, `AI_ATTACK_FORCE` 60→260 | `app/scripts/data.gd:63,64` = 260.0 / 40 | CONFIRMED | `app/config.json` ships `attack_force: 120.0` — see §4 (intentional G3 tuning, not a doc error). |
| 24 | GUIDE2 S2 L144-156 / S4 L438 | `cen_18c`, `bar18`, `dip`, `gat` exist; `aca_18c` removed | `app/scripts/data.gd:709` (`cen_18c`), `:657` (`bar18`), `:660` (`dip`), `:681` (`gat`); no `aca_18c` match | CONFIRMED | — |
| 25 | GUIDE3 L62 | "Sim (`game.gd`, **2159 lines**)" | `app/scripts/game.gd` → 3719 lines | **STALE → FIXED** | Edited to "3719 lines as of 2026-11-21; 2159 at G3 authoring". |
| 26 | GUIDE3 L63 | `main.gd _process L386–400` accumulator, "max 64 steps/frame" | `app/scripts/main.gd:888` (`func _process`), `:914` (`while acc >= step and steps < 64`) | STALE anchor / CONFIRMED rule | Anchor moved +502/+528; "max 64" still true. Anchor not renumbered. |
| 27 | GUIDE3 L57 | gate "selftest 28/28 and uitest 17/17" | `app/selftest.json` 29 steps / 28 passing; `app/uitest.json` 17 steps | CONFIRMED | Current selftest run is 28/29 because farm_cap fails (board P-04) — gate still documented as 28/28. |
| 28 | GUIDE3 L68-70 | "40+ upgrades" | `app/scripts/data.gd`: 50 `UPGRADES_BASE` entries with `"building"` | CONFIRMED | — |
| 29 | GUIDE3 L105 | "`--seed` parsed but IGNORED (main.gd L343–345)" | `app/scripts/main.gd:135-136` (`elif seed_arg >= 0: Data.RANDOM_SEED = seed_arg`), `:663-668` (arg parse) | **STALE → FIXED** | Edited to note it was ignored at authoring and is now applied (GUIDE4 L6). Anchor also drifted. |
| 30 | GUIDE3 L2337 | "sheet_metrics.py measured 209 sheets" | `app/assets/models/anim/` has 1806 PNGs incl. stage/death variants; 54 index keys | UNVERIFIABLE | "209 sheets" was a tool measurement at authoring; not re-run (out of scope). Plausible (54 units × 4 actions = 216). |
| 31 | TERRAIN L6-11 | donor script sizes 109/52/13/49/70 KB | donor files → 109219 / 51794 / 13193 / 48954 / 70074 bytes | CONFIRMED | — |
| 32 | TERRAIN L28 | "This part is already ported in `app/scripts/mapgen.gd`" | `app/scripts/mapgen.gd:2-8` (mask/height/threshold docs), `:51` (`relief`), `:63` (`_starts_from_mask`), `:115-123` (height/forest/starts) | CONFIRMED | — |
| 33 | TERRAIN L66-67 | "already sketched in GUIDE4 L3 (`_claim_cluster`, paint-then-scatter, clear radius > paint radius)" | `docs/guides/GUIDE4.md:423` ("L3 — CLUSTERING"), `:146`, `:220`, `:442`, `:473` | CONFIRMED with drift | "L3" is a GUIDE4 **layer** label, not a stable absolute line; L3 section is now at absolute line 423 and the concept anchors moved. Worker C's finding (L170/L181/L203 → L224/L235/L273) is consistent with the exploded-edition numbering. Not renumbered. |
| 34 | TERRAIN L73 | "winter0..26" donor tile family converted | `app/assets/terrain/blocks/winter*.png` → 27 files (0..26) | CONFIRMED | — |
| 35 | TERRAIN L74 | `diffusewaves0..7.png` | `app/assets/terrain/water_png/diffusewaves{0..7}.png` → 8 files | CONFIRMED | — |
| 36 | videos.md L9 | "Videos (**14 distinct**, incl. the two requested)" | the same file lists 17 numbered entries (L11-27) | **STALE → FIXED** | Edited to "17 distinct". |
| 37 | videos.md L48 | pikeman `prot [pike2 sword3 bullet7 arrow4 cannon40 grapeshot210]` ... "port already correct" | `app/scripts/data.gd:233` (slot order `[pike,sword,bullet,cannister,arrow,cannonball]`), `:251` (`prot [3,2,4,210,6,40]`) | UNVERIFIABLE / apparent mismatch | Port values differ from the wiki-derived list. Mechanics values are worker I's ownership (do not edit here); flagged in §4. |

**Tally:** 37 claims checked — CONFIRMED 19 (incl. 2 dated STATUS snapshots and
1 with drift), STALE 15 (5 fixed; 10 drift/date-only, deliberately not
renumbered), UNVERIFIABLE 3; 2 rows are mixed CONFIRMED/UNVERIFIABLE (Godot
version) and STALE-anchor/CONFIRMED-rule (max-64 steps). See per-row text.

## 2. Drifted anchors — noted, NOT renumbered

Per task instruction, no line anchor was renumbered. Representative drift
(current → old) found in GUIDE1/2/3:

| Doc section | Old anchor | Current location | Δ |
|---|---|---|---|
| GUIDE1 §3 | world.gd L32/L37/L40 | L64/L81/L84 | +32/+44/+44 |
| GUIDE1 §3 | world.gd L83/L119/L122/L132 | L169/L208/L214/L483 | +86…+351 |
| GUIDE1 §3 | world.gd L112 `_unit_height` | L201 | +89 |
| GUIDE1 §3 | game.gd L332 `spawn` | L1229 | +897 |
| GUIDE1 §3 | game.gd L613/L687/L721 | L1849/L1928/L1965 | +1236/+1241/+1244 |
| GUIDE1 §3 | game.gd L761/L850/L858/L900/L1072/L1147 | L2019/L2178/L2186/L2301/L2538/L2789 | +1258…+1642 |
| GUIDE1 §3 | data.gd L117/L428 | L167/L821 | +50/+393 |
| GUIDE2 §1 | hud.gd ~L322 | L459 | +137 |
| GUIDE3 §1 | main.gd L386–400 | L888 / L914 | +502/+528 |
| GUIDE4 (worker C) | L170/L181/L203 | L224/L235/L273 | +54/+54/+70 |

All guides are paste-ready *historical* execution plans with dated STATUS
blocks; their anchors describe the files as of authoring (2026-11-18/19), which
is why they drifted rather than being wrong at the time. `GUIDE4.md` was not
edited (line-count contract).

## 3. Stale statements fixed (minimal diffs)

| File | Line | Before → After |
|---|---|---|
| `docs/guides/GUIDE1.md` | L38 | "NOT git" → "Git repo (initialised after this guide was written; it was NOT git on 2026-11-18)" |
| `docs/guides/GUIDE2.md` | L65 | "selftest.gd 21 steps" → "selftest.gd 29 steps (28-pass gate; 21 at GUIDE2 authoring)" |
| `docs/guides/GUIDE3.md` | L62 | "game.gd, 2159 lines" → "game.gd, 3719 lines as of 2026-11-21; 2159 at G3 authoring" |
| `docs/guides/GUIDE3.md` | L105 | "`--seed` parsed but IGNORED (main.gd L343–345)" → "... IGNORED at authoring ... — now applied via main.gd L135–136 (GUIDE4 L6)" |
| `reference/videos.md` | L9 | "Videos (14 distinct...)" → "Videos (17 distinct...)" |

`docs/TERRAIN_GEN_RESEARCH.md` needed **no** edit: all its donor-source and
asset claims checked out (rows 31-35). Backups of all five source docs were
saved as `inbox\backup\<name>.bak-agentX` before any edit.

## 4. Open questions / out-of-scope findings

1. **`apply_damage` slot indexing (board P-06).** `data.gd:233` maps
   `cannonball → 7` and `arrow → 5`, but `prot` arrays have 6 slots (`:831-834`
   guards `pi < prot.size()`). Cannonball protection therefore never applies.
   Owned by worker A / board P-06 — not touched here.
2. **Pikeman `prot` mismatch (row 37).** `videos.md:48` quotes wiki values that
   differ from `data.gd:251`; worker I owns mechanics; not adjudicated here.
3. **`attack_force` divergence.** `data.gd:63` = 260.0, `config.json` = 120.0.
   `GUIDE3.md` STATUS says "attack_force 260→120 ... DEFAULT remains 60" — the
   "DEFAULT remains 60" clause is itself stale (current default is 260). AI is
   worker G's active ticket (G-01), so no edit made; confirm after G-01 closes.
4. **Exact Godot patch version** (row 1) needs `godot --version`, which requires
   the runner and was intentionally not run for this docs-only task.
5. **Cookbook note.** GUIDE1 S1 Phase A command still invokes bare `godot`;
   current protocol requires `app/tools/godot_runner.py` (SWARM_OPS gate 1).
   Left as-is: guides are historical execution plans, and `docs/COMMANDS.md`
   (worker E) is the current runner manual.
