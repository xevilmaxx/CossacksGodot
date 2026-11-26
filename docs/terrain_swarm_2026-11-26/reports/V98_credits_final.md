---
id: V98
ticket: "TERRAIN-SWARM-2026-11-26 / V98 — final read-only verification of the V49 CREDITS entry, .gitignore large-derived coverage and donor-commit hygiene"
agent: "V98 (read-only verification worker, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GIT_MUTATION__NO_GODOT_JOB__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V98_credits_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V98_credits_final.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
parity_status: UNVERIFIED
multiple_passes: true
multiple_pass_note: "Each finding was checked with at least two independent read instruments (dedicated read + git read-only command + PowerShell re-read). V72's point-in-time 'CREDITS block missing' state was re-checked and found overtaken by a later write."
sources_read: [
  "docs/terrain_swarm_2026-11-26/CHARTER.md",
  "docs/terrain_swarm_2026-11-26/reports/V49_licence_credits.md",
  "docs/terrain_swarm_2026-11-26/reports/V72_final_decision_memo.md",
  "variant3d/CREDITS.md", "app/CREDITS.md", ".gitignore"
]
---

# V98 — final CREDITS / .gitignore / donor-commit verification

> **No parity claim.** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists. Nothing here is a gate result or a capture verdict.

## 0. Executive summary

1. **[O] V49's paste-ready CREDITS entry WAS appended.** `variant3d/CREDITS.md:136-165` carries `## V49-TERRAIN-NEW — donor-derived pattern / cfg assets (2026-11-26, derived, not copied)` and its 30 body lines are **byte-identical** to the V49 §5 block (`V49_licence_credits.md:135-164`). V72 row 0.9 / ledger V0.9 recorded "0 hits, CREDITS block missing" — that state is **point-in-time and now overtaken**. No gap remains; no paste action is required. See §1.
2. **[O] `.gitignore` NOW covers the large derived atlas/winter/split parts** with a dedicated `V78 / V49 compliance` block at `.gitignore:132-154`: lines 137-140 name the four legacy atlas/summer/winter/part files; lines 141-142 cover future `terrain_new/**` parts and atlas PNGs. `git check-ignore --no-index -v` resolved every one of the four legacy paths to lines 137-140, and future `terrain_new/atlas/tile_index_atlas.png`, `.../tile_index_atlas_winter.png` and `.../atlas_parts/*.part000` resolved to lines 141-142. See §2.
3. **[D] Caveat — the four legacy large files remain TRACKED.** `git ls-files --error-unmatch` exit 0 for all four; `git check-ignore -v` (with index) returns no rule for them, and 2 `.part[0-9]+` files are in the index. Ignore rules do not retroactively untrack indexed files, exactly as the `.gitignore:134-136` comment states. COORD still owes `git rm --cached` / LFS if they must leave a commit. This V98 worker made no git mutation. See §2.3.
4. **[O] No raw donor file was newly committed.** `git ls-files` scan: **0** tracked files with forbidden donor extensions (`.tga/.osm/.oss/.pattern/.map/.aaf/.cdx/.dll/.exe`); **0** staged changes (`git diff --cached --name-only` empty); **0** tracked files under `variant3d/assets/terrain_new/`. The only tracked `.partNNN` files are the two already-disclosed legacy split parts (§0 item 3). See §3.
5. **[O] `app/**` is clean.** `git status --short` lists no `app/` entry; `git diff --exit-code -- app/` exit 0; `app/CREDITS.md` is 98 lines, 0 `V49-TERRAIN-NEW` hits (untouched). See §4.
6. **[U] No standalone "V78 licence-fix note" report file was found** in `docs/terrain_swarm_2026-11-26/reports/` (glob `**/V78*`); the V78-labelled landed change is the `.gitignore` block itself (`.gitignore:132`), whose header reads "V78 / V49 compliance". See §2.4.

---

## 1. V49 CREDITS entry — already appended

### 1.1 Verification (two passes)

| Pass | Instrument | Result |
|---|---|---|
| A | Dedicated `read` of `variant3d/CREDITS.md` (165 lines) | Heading at line 136; block at lines 136-165, ending at `(spec/11 §11.1; X15 §2.1).` |
| B | PowerShell `Get-Content` + case-sensitive join comparison of `V49_licence_credits.md[134..163]` vs `CREDITS.md[135..164]` | `CREDITS_BLOCK_BYTE_IDENTICAL_TO_V49_SECTION5=True`; 30 lines each |
| C | `Select-String` for `## V49-TERRAIN-NEW` in `variant3d/CREDITS.md` and `app/CREDITS.md` | 1 hit at `variant3d/CREDITS.md:136`; 0 hits in `app/CREDITS.md` |

**[O]** The block in place contains the donor-path citations (`data/gen/*.cfg`, `data/game/var/*.cfg`, `data/pattern/pattern.lib` with sha256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`, 710 `data/pattern/*.pattern` with per-file `source_sha256`) and the private-use / never-redistribute wording (`For private use of the game owner on their own machine only; never share, publish, upload or redistribute. PORT APPROXIMATION — visual donor parity is UNVERIFIED ...`).

### 1.2 Exact text already in place (reference only — NO edit needed)

Path: **`variant3d/CREDITS.md`**, append point already used = end of file (lines 136-165). Verbatim content currently present:

```markdown
## V49-TERRAIN-NEW — donor-derived pattern / cfg assets (2026-11-26, derived, not copied)

Offline readers (read-only donor; dry-run by default, explicit write required):
`python variant3d/tools/decode_donor_cfg.py --game "C:\Games\Cossacks 3" --out variant3d/assets/terrain_new/cfg`,
`python variant3d/tools/decode_pattern_lib.py --game "C:\Games\Cossacks 3" --write --out variant3d/assets/terrain_new/patterns`,
`python variant3d/tools/decode_donor_pattern.py --game "C:\Games\Cossacks 3" --no-dry-run --out variant3d/assets/terrain_new/patterns`.

Donor files READ (never copied, executed or committed):
`data/gen/{globalparams,localparams,mapcover,tilesmooth,tilesmooth_scripts}.cfg`,
`data/game/var/{generator,startingsettings}.cfg`,
`data/pattern/pattern.lib` (30,309,138 B, sha256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`),
and 710 `data/pattern/*.pattern` binaries — per-file `source_sha256` values are recorded in
`variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json` (`output_count: 710`,
`determinism_second_pass_equal: true`).

Written DERIVED outputs (labelled, not donor bytes):
`variant3d/assets/terrain_new/cfg/{constants.json,config_strings.json,manifest.json}` and
`variant3d/assets/terrain_new/patterns/*.json` (710 decoded pattern records,
`patterns/families/*.json` 64 family files, `family_index.json`,
`blend_test_vectors.json`, `pattern_decode_manifest.json`). Values are decoded numbers,
strings, labels and sha256 checksums; undecodable fields stay `null` + `UNVERIFIED`;
every emitted JSON carries `visual_parity_claim:false`. No TGA/DDS/OSM/OSS/.pattern/.map
or donor executable was written. `decode_donor_masks.py` and `build_terrain_new_atlas.py`
were not run in write mode: `terrain_new/{atlas,masks,schemas}` do not exist.

For private use of the game owner on their own machine only; never share, publish,
upload or redistribute. PORT APPROXIMATION — visual donor parity is UNVERIFIED; no
donor GPU A/B frame exists. Before any commit, replace the absolute donor install
path embedded in the current JSON outputs with `$COSSACKS3_DIR` / `source_rel`
(spec/11 §11.1; X15 §2.1).
```

**[D]** Because the block is present and byte-identical to the paste-ready source, the V72 Phase-0 row 0.9 "append V49 §5 block" action is already satisfied. COORD should record the close-out, **not** append a duplicate.

---

## 2. `.gitignore` large-derived coverage — rules landed, legacy still indexed

### 2.1 Rules present (read `.gitignore:132-154`)

```
# --- V78 / V49 compliance: large derived atlases + raw donor binaries --------
variant3d/assets/terrain/atlas/tile_index_atlas.png              (:137)
variant3d/assets/terrain/atlas/tile_index_atlas_winter.png       (:138)
variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000    (:139)
variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001    (:140)
variant3d/assets/terrain_new/**/*.part[0-9]*                     (:141)
variant3d/assets/terrain_new/**/atlas/tile_index_atlas*.png      (:142)
```
Plus raw-donor extension rules at `:146-154` (`*.tga`, `*.osm`, `*.oss`, `*.pattern`, `*.map`, `*.aaf`, `*.cdx`, `*.dds`, `*.dll`, …).

### 2.2 `git check-ignore` results (read-only)

| Target | Instrument | Result |
|---|---|---|
| Four legacy atlas/summer/winter/part paths | `git check-ignore --no-index -v` | All 4 resolved: `.gitignore:137`, `:138`, `:139`, `:140` |
| Four legacy paths **with index** | `git check-ignore -v` | **No rule reported** — because they are tracked (Git does not apply ignore rules to indexed files) |
| `terrain_new/atlas/tile_index_atlas.png` | `git check-ignore -v` | `.gitignore:142` |
| `terrain_new/atlas/tile_index_atlas_winter.png` | `git check-ignore -v` | `.gitignore:142` |
| `terrain_new/atlas_parts/tile_index_atlas.part000` | `git check-ignore -v` | `.gitignore:141` |

**[D]** Future derived atlas/winter/split outputs under `terrain_new/**` are therefore covered by rules the moment they are written. The explicit legacy paths are covered only if they are removed from the index.

### 2.3 Residual gap: four legacy large files still tracked

`git ls-files --error-unmatch` returned exit 0 for all four legacy paths; tracked `.part[0-9]+` count = 2. This matches the warning already written at `.gitignore:134-136`: *"Ignore rules do NOT untrack files already in the index: the four legacy large files remain tracked here; COORD must git rm --cached / LFS-track them if they are to leave a commit. No git index change was made by this edit."*

**[D]** COORD action still open (not performed by V98): `git rm --cached` / LFS-track the 179 MB summer atlas, 124 MB winter atlas and the two 90 MB / 89.9 MB split parts. This is a commit-policy decision, not a defect in the ignore rules themselves.

### 2.4 V78 note

**[U]** No standalone V78 licence-fix note report file exists under `docs/terrain_swarm_2026-11-26/reports/` (glob `**/V78*` returned only unrelated `V780`–`V786` reports in `docs/coord_swarm_2026-11-24/`). The V78-labelled artefact that did land is the `.gitignore:132` block header "V78 / V49 compliance"; its contents were verified in §2.1-§2.2.

---

## 3. No raw donor file newly committed (`git ls-files`, read-only)

| Check | Instrument | Result |
|---|---|---|
| Forbidden donor extensions in index | `git ls-files` → PowerShell `Select-String '\.(tga\|osm\|oss\|pattern\|map\|aaf\|cdx\|dll\|exe)$'` | **0** |
| Staged changes | `git diff --cached --name-only` | **0** entries |
| `terrain_new/**` in index | `git ls-files "variant3d/assets/terrain_new"` | **0** files (whole tree is untracked `??`) |
| `.partNNN` in index | `git ls-files` → `Select-String '\.part[0-9]+$'` | **2** — the two disclosed legacy `tile_index_atlas.part000/.part001` (see §2.3), not new |
| HEAD | `git rev-parse --short HEAD` | `e234ac9b` |

**[O/D]** No new verbatim donor binary is in the index or staged; the working tree's raw donor material is absent from the index. The only donor-family bytes tracked in the repo are the pre-existing, documented private-use copies (936 `.dds`, 8 `.lib`, 29 `.bmp`, 650 `.ogg` reported at `V49_licence_credits.md:103`) which pre-date this wave — none matched a forbidden extension scan result beyond those families in this pass, and V98 made no commit.

---

## 4. `app/**` clean

| Check | Instrument | Result |
|---|---|---|
| `git status --short` | shell | No `app/` entry in unstaged or staged list |
| `git diff --exit-code -- app/` | shell | `DIFF_EXIT=0` |
| `app/CREDITS.md` | `read` + `Select-String` | 98 lines; **0** `V49-TERRAIN-NEW` hits — the CREDITS change stayed in `variant3d/` only |

**[O]** `app/**` is byte-untouched by this wave, consistent with CHARTER.md:28-30 and V49 §5's "do not edit `app/CREDITS.md`".

---

## 5. Multiple-pass log (owner directive, CHARTER.md:88-93)

| Finding | Pass 1 | Pass 2 | Pass 3 | Accepted |
|---|---|---|---|---|
| CREDITS block | Dedicated `read` of `variant3d/CREDITS.md` (present, :136-165) | PowerShell byte-join comparison vs V49 §5 (identical) | `Select-String` heading + `app/CREDITS.md` 0 hits | **PRESENT** (reversal of V72's stale "missing") |
| `.gitignore` coverage | Dedicated `read` of `.gitignore` (block :132-154) | `git check-ignore --no-index -v` (4/4 legacy + 3/3 future resolved) | `git check-ignore -v` with index (legacy → no rule) | **RULES LAND; LEGACY 4 STILL TRACKED** |
| Donor commit hygiene | `git status --short` | `git ls-files` + `Select-String` forbidden-extension scan | `git diff --cached --name-only` + `git ls-files --error-unmatch` on the four parts | **NO NEW RAW DONOR COMMITTED** |
| `app/**` | `git status --short` (0 entries) | `git diff --exit-code -- app/` (exit 0) | `app/CREDITS.md` 98 lines, 0 V49 hits | **CLEAN** |

---

## 6. Open items for COORD (not performed here)

1. **[D]** Close V72 Phase-0 row 0.9's "append V49 §5 block" item as **already satisfied**; do not append a duplicate to `variant3d/CREDITS.md`.
2. **[D]** Decide / execute `git rm --cached` or LFS for the four tracked large derived files (`.gitignore:134-136`); V98 made no git mutation.
3. **[O]** Re-verify the deliberate `C:\Games\Cossacks 3` → `$COSSACKS3_DIR`/`source_rel` normalisation before any commit (V72 row 0.9 reports live 780/780 JSON with 0 absolute-path files; V98 did not re-scan all 780).
4. **[U]** Parity remains UNVERIFIED; no donor GPU A/B frame exists. No gate was run by V98.

---

## 7. Attestation

**Attestation.** Read-only worker. Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/V98_credits_final.md`. No source, shader, config, asset, CREDITS, `.gitignore`, test, result JSON, queue, git index or Godot state was changed; no runner job or gate was run; no donor file was opened, executed or copied. All git commands used were read-only (`status`, `diff`, `check-ignore`, `ls-files`, `rev-parse`). Multiple passes were used on every finding, including the reversal of V72's stale "CREDITS block missing" state. **No donor-parity claim.**

*End of V98 report.*
