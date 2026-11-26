---
id: V49
ticket: "TERRAIN-SWARM-2026-11-26 / V49 — licence, CREDITS and private-use compliance audit of the fresh terrain port"
owner: V49 (read-only verification worker; 30-agent DONOR-FIRST terrain swarm)
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GIT_MUTATION
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read first: docs/terrain_swarm_2026-11-26/{CHARTER,SWARM_BOARD}.md, app/CREDITS.md, variant3d/CREDITS.md, spec/11_ASSET_CONVERSION.md, reports/{X15_asset_manifest_skeleton,A03_asset_pipeline}.md. Then read-only filesystem/hash/git inspection of the repo and of C:/Games/Cossacks 3."
outputs: "Exactly one repo file: docs/terrain_swarm_2026-11-26/reports/V49_licence_credits.md. No scratch file written inside the repo."
donor_handling: "C:/Games/Cossacks 3 was opened read-only for hashes only. No donor executable was run, no donor byte was written, copied back to the donor, or executed."
parity_guard: "No donor GPU A/B frame exists. Every port-side statement is PORT APPROXIMATION / UNVERIFIED; this report makes no donor-parity claim."
---

# V49 — licence / CREDITS / private-use audit of the fresh terrain port

## 0. Executive summary

1. **[O] Multi-pass contradiction resolved (owner directive, CHARTER.md:88-93).** Pass 1 (start of this audit) reported `variant3d/assets/terrain_new/**` **absent** and no new asset files in `git status`. Pass 2, minutes later, found the directory **present** with 780 files / 242,316,351 B, mtimes 09:58:40–10:00:57 on 2026-11-26. Pass 3 (independent Python walk) and Pass 4 (git re-check) reproduced the Pass-2 state. **[D]** This is a concurrent-writer race inside the 30-agent swarm, not a hash contradiction: implementation workers wrote the assets during this audit. All inventory below is a **point-in-time snapshot** (final re-check ~10:01 local).
2. **[O/D] Donor material was READ; only derived JSON was WRITTEN.** The new readers are wired to read `data/pattern/*.pattern` (710 files), `data/pattern/pattern.lib`, seven `data/gen/*.cfg` + `data/game/var/*.cfg`, and (in a decoder that wrote nothing) `data/gen/terrainmasks*/**/*.tga`. The written outputs are **780 JSON files** under `variant3d/assets/terrain_new/{cfg,patterns}/**`. No `.tga`, `.dds`, `.osm`, `.oss`, `.pattern`, `.map` or donor `.exe` was written today; `terrain_new/{atlas,masks,schemas}` do **not** exist.
3. **[O] No NEW verbatim donor copy was created today.** However, the repo already **tracks** verbatim donor files: 936 `.dds`, 8 `.lib`, 29 `.bmp`, 650 `.ogg`. Two independent hash instruments (PowerShell `Get-FileHash` and Python `hashlib`) matched five sampled repo files byte-for-byte against exact donor paths (§4). Their mtimes (2019-03-03 / 2026-11-13 / 2026-11-20) pre-date today's terrain port; they are pre-existing, documented private-use copies (`app/CREDITS.md:7-34`, `variant3d/CREDITS.md:7-34`, `docs/WAIVERS.md:36-64`), not a new violation by this wave.
4. **[O] `variant3d/CREDITS.md` DOES need a new entry** for the new derived pattern/cfg assets; `app/CREDITS.md` must **not** be touched (CHARTER.md:28-30, `app/` byte-identical verified: `git diff --exit-code -- app/` exit 0, 0 status entries). Paste-ready text is in §5.
5. **[O] `.gitignore` does NOT cover any of the large derived assets.** `git check-ignore -v` returns **NO RULE** for the 179,912,941 B summer atlas, the 124,463,306 B winter atlas, the two split parts, and for hypothetical future `terrain_new` atlas/part files. Worse, the four legacy large files are **already TRACKED**; an ignore rule alone would not untrack them (§6).
6. **[O] A compliance defect exists in the new derived JSON:** 714 of 780 files (9,304 occurrences) embed the **absolute private install path** `C:\Games\Cossacks 3`, contrary to A03 §2.2.5 / X15 §2.1 (`donor_root_policy`: value NOT recorded as an absolute path in committed output). The files are still untracked; COORD should strip/relativise before any commit.
7. **[O] Every one of the 780 derived JSON files carries `visual_parity_claim:false`** (0 with `true`, 0 missing; Pass 3 parsed all 780 with `json.loads`, 0 parse failures). No parity claim exists. **[U]** The visual result remains UNVERIFIED.

---

## 1. Evidence table

Label key: **[O]** literal path:line / on-disk count / hash computed this pass; **[D]** deterministic consequence of observed data; **[I]** reasonable reading without a run; **[U]** cannot be proven from this pass; **PORT APPROXIMATION** = explicit port substitute. No donor parity claim anywhere.

| # | Evidence (path:line / artifact) | Fact | Label |
|---|---|---|---|
| E1 | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-30,64-69,82-93,125`; `IMPLEMENTATION_PLAN.md:23-32` | Donor read-only/private use; no donor binary copied or executed; labels mandatory; no parity without GPU A/B; multiple passes on contradictions; `app/` byte-identical | [O] |
| E2 | `docs/terrain_swarm_2026-11-26/spec/11_ASSET_CONVERSION.md:8-18,40-59,61-64`; `reports/A03_asset_pipeline.md:74-80,210-238,258-268` | Disjoint `terrain_new/**`; donor root is input only; `inputs_never_committed`; `visual_parity_claim:false`; large atlas + split parts uncommitted/LFS | [O] |
| E3 | `docs/terrain_swarm_2026-11-26/reports/X15_asset_manifest_skeleton.md:17-23,44-79,222-224` | Manifest schema; deterministic pack id; 179,912,941 B summer / 124,463,306 B winter / 90,000,000 + 89,912,941 B split parts never commit; `pattern.lib` hash anchor | [O] |
| E4 | Pass 1 `Test-Path` = False; Pass 2 `Get-ChildItem -Recurse` on `variant3d/assets/terrain_new`; Pass 3 Python `os.walk`+`json.loads`; Pass 4 `git status` re-check | 780 files / 242,316,351 B; 714 embed absolute donor path; 780 parse as JSON; 780 `visual_parity_claim:false`; 776 contain `source_sha256`; concurrent appearance explained | [O]/[D] |
| E5 | `variant3d/tools/decode_donor_cfg.py:46-98,785-808,865-869`; `decode_pattern_lib.py:52-54,398-405,1131-1173`; `decode_donor_pattern.py:77-78,852-879,961-966`; `decode_donor_masks.py:45-54,589-610`; `build_terrain_new_atlas.py:64-84,459-495,902-950` | Exact donor inputs each tool reads, output roots, dry-run defaults, licence guards | [O] |
| E6 | `variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json:1-30` (head), `output_count=710`, `determinism_second_pass_equal=true`, per-file `source_sha256`; `variant3d/assets/terrain_new/cfg/manifest.json:1-25` (3-pass count checks) | Derived provenance recorded; per-file donor hashes; deterministic second pass | [O] |
| E7 | Read-only `C:\Games\Cossacks 3\data\pattern\pattern.lib` = 30,309,138 B, sha256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0` (Pass 2 `Get-FileHash`, Pass 4 Python `hashlib`) | Anchor equals `mountain_props.json:4`, X15 E9 and the value embedded in new family JSONs | [O] |
| E8 | Pass 4: four `source_sha256` values in `pattern_decode_manifest.json` vs live donor `.pattern` hashes (`b_frt_b_p_1/2/3`, `b_str_3`) | 4/4 exact match | [O] |
| E9 | `git ls-files` + `Get-FileHash` + Python `hashlib`: 936 `.dds`, 8 `.lib`, 29 `.bmp`, 650 `.ogg` tracked; five sampled pairs matched donor (§4) | Verbatim donor copies are present in the repo and tracked; pre-existing | [O] |
| E10 | `git check-ignore -v` for legacy and hypothetical `terrain_new` atlas/part paths => NO RULE; `git ls-files --error-unmatch` => four large files TRACKED | `.gitignore` provides no protection; tracked files stay tracked | [O] |
| E11 | `docs/WAIVERS.md:57-64`; `README.md` licence block (~lines 215-224); `app/CREDITS.md:1-5,98` | Owner-facing compliance statement: private use by game owner, own machine, never share/publish/redistribute | [O] |
| E12 | `docs/terrain_swarm_2026-11-26/HANDOFF.md:19,45-66,151` (V29 snapshot ~09:47) | Draft handoff says `terrain_new/**` absent and no donor copy; now stale on `terrain_new` (assets appeared 09:58-10:01) | [O]/[D] |

---

## 2. Read-vs-written inventory

### 2.1 Donor files READ (read-only, private install)

| Donor path (relative to `C:\Games\Cossacks 3`) | Reader / evidence | Written? | Label |
|---|---|---|---|
| `data\pattern\*.pattern` (710 files, e.g. `hil1.pattern`, `b_frt_b_p_1.pattern`, `k_ravine_big_stone_1.pattern`) | `decode_donor_pattern.py:852-879`; `pattern_decode_manifest.json` `output_count=710` with per-file `source_sha256` | No — only decoded JSON | [O]/[D] |
| `data\pattern\pattern.lib` (30,309,138 B) | `decode_pattern_lib.py:52-54`; `decode_donor_pattern.py:858`; X15 E9; Pass 4 re-hash | No — hash + plaintext records only | [O] |
| `data\game\var\generator.cfg`; `data\game\var\startingsettings.cfg` | `decode_donor_cfg.py:88-98` | No — values recorded in `cfg/*.json` | [O] |
| `data\gen\globalparams.cfg`, `localparams.cfg`, `mapcover.cfg`, `tilesmooth.cfg`, `tilesmooth_scripts.cfg` | `decode_donor_cfg.py:46-86` (7 FILE_SPECS total with the two above) | No — values/strings in `cfg/*.json` | [O] |
| `data\gen\terrainmasks\**\*.tga`, `terrainmasks.dlc5`, `terrainmasks.src` | `decode_donor_masks.py:45-54,293` | **No output at all** — `terrain_new/masks` absent; decoder present but not run in `--write` mode | [O]/[U] |
| `data\terrain\ref\reftilealpha.mat`, `reftile.mat`; `data\terrain\tiles\tiles.mat`, `terrain.presets` | Cited as donor evidence inside `build_terrain_new_atlas.py:102-108,280-306,504-509,588-611`; tool docstring says `--game` is licence guard only, never read (`:906-907`) | No atlas written | [O]/[I] |
| `cossacks.exe`, `editor.exe`, DScript/cfg corpus | Research workers D/F/X waves; summarised in `HANDOFF.md:27-40` | No — reports only | [O inherited] |

**[U]** The exhaustive set of donor files touched by every worker today cannot be reconstructed from the filesystem alone; the table covers the wired readers plus the independently re-hashed anchors. No donor file was executed by V49.

### 2.2 Derived assets WRITTEN (this wave, under `variant3d/assets/terrain_new/**`)

| Output group | Files | Bytes | Evidence / content | Label |
|---|---:|---:|---|---|
| `cfg/constants.json`, `cfg/config_strings.json`, `cfg/manifest.json` | 3 | 3,756,649 | donor cfg key/value lines + labels; `config_strings.json` includes verbatim donor text lines (`raw`), not donor binaries | [O]/[D] |
| `patterns/*.json` (710 per-pattern records) | 710 | — | `schema: terrain_new.pattern_decode.v1` (e.g. `hil1.json:1`), `byte_closure` regions, occupancy, decoded grid, `source_sha256` | [O]/[D] |
| `patterns/families/*.json` | 64 | 46,555,804 | per-family metadata, `HeightFieldMax` observations, `pattern.lib` hash anchor | [O]/[D] |
| `patterns/family_index.json`, `blend_test_vectors.json`, `pattern_decode_manifest.json` | 3 | 55,507,231 + 15,756 + 303,454 | 64-family index, 710-output provenance, `determinism_second_pass_equal=true` | [O] |
| **Total `terrain_new`** | **780** | **242,316,351** | 100% `.json`; **all untracked** (782 `git status` entries incl. directory rows) | [O] |
| `terrain_new/atlas/**`, `terrain_new/masks/**`, `terrain_new/schemas/**`, root `terrain_new/manifest.json` | 0 | 0 | **absent** at final check — I04/I05 write modes and root manifest builder have not produced outputs | [O] |

**[O] Provenance quality:** 780/780 JSON files parse and carry `visual_parity_claim:false`; 776/780 carry `source_sha256`; `pattern_decode_manifest.json` labels are `source=[O]`, `derived=[D]`, `parity=[U]`, `undecodable=[U] null + UNVERIFIED`.

**[O] Compliance defect (not yet committed):** the absolute donor path `C:\Games\Cossacks 3` appears in 714/780 files (9,304 occurrences; examples: `cfg/config_strings.json` 4,868, `cfg/constants.json` 3,001, every per-pattern JSON once). This violates `A03 §2.2.5` and `X15 §2.1` (`donor_root_policy` must not record the absolute install path in committed bytes). **[D]** Remedy before commit: replace with `$COSSACKS3_DIR` / `source_rel` (both fields already present in cfg JSONs) and re-run the manifest builder.

---

## 3. Copy violations — verbatim donor bytes in the repo

### 3.1 New violations from today's terrain port: **NONE observed** [O]

- Extension scan over the whole working tree (excluding `.git`) found **no** `.tga`, `.osm`, `.oss`, `.pattern`, `.map`, donor `.exe`, `.cdx` or donor `.dll` under any new path. The 780 new `terrain_new` files are all `.json` and contain decoded numbers/strings plus provenance, not donor binaries.
- Donor `cossacks.exe` sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` (5,768,048 B) was compared against **all 27 repo `.exe` files** (all under `rustport/target/**`, i.e. Rust build outputs): **0 matches**.
- `git status` shows 0 entries under `app/`; `git diff --exit-code -- app/` exit 0.

### 3.2 Pre-existing verbatim donor copies: **FOUND, tracked, documented** [O]

Two independent hash instruments (PowerShell `Get-FileHash -Algorithm SHA256`, then Python `hashlib.sha256`, 1 MiB chunks) gave identical hashes and zero contradictions.

| Repo path (exact) | Donor path (exact, read-only) | Bytes | SHA-256 (both passes) |
|---|---|---:|---|
| `app/assets/terrain/decals/ukrcend.dds` | `C:\Games\Cossacks 3\data\terrain\decals\buildings\ukrcend.dds` | 1,398,256 | `1590d9ec99c410635deb6ecca249a0c81741dac8c93ce21741a4b5f50c0fd2db` |
| `variant3d/assets/terrain/decals/ukrcend.dds` (hardlinked twin) | same donor file | 1,398,256 | `1590d9ec99c410635deb6ecca249a0c81741dac8c93ce21741a4b5f50c0fd2db` |
| `app/assets/terrain/decals_dds/decals_dlc1.lib` | `C:\Games\Cossacks 3\data\terrain\decals\buildings\decals_dlc1.lib` | 5,564 | `4016040d4b2f724047d676a982c9b4dbe48166349e7710ad672cb95343d08d57` |
| `app/assets/terrain/decals_dds/algcend.dds` | `C:\Games\Cossacks 3\data\terrain\decals\buildings\algcend.dds` | 1,398,256 | `6e99642ff49adf98ba02ffc50caa85e36d4241116a14775500335746d8e58394` |
| `app/assets/ui/icons.bmp` | `C:\Games\Cossacks 3\data\hud\textures\ui\icons.bmp` | 2,097,208 | `a6ec7c060db8a805dbe28a341d70e1f5ae589e2fb0936ebdd40b925881f45b4f` |
| `app/assets/sounds/musket1.ogg` | `C:\Games\Cossacks 3\data\sounds\units\musket1.ogg` | 266,576 | `0ecf763aa86c346eafce6c13df9b5bb4cc1ea3f57ed6fdfdd346aaaa9e47f9bc` |

**[O] Scale:** `git ls-files` reports 936 tracked `.dds`, 8 `.lib`, 29 `.bmp`, 650 `.ogg` — the families disclosed in `app/CREDITS.md:7-34` and `variant3d/CREDITS.md:7-34`. **[U]** Only five pairs were hash-verified; the remaining files are inferred from path/family disclosure, not individually hashed this pass. **[O]** Their mtimes are 2019-03-03 (`ukrcend.dds`), 2026-11-13 (`icons.bmp`), 2026-11-20 (`decals_dlc1.lib`) — well before today's terrain port. These are **documented private-use copies**, not a new copy violation, but they must never be shared or published (§7 statement).

---

## 4. Large derived files — commit policy and `.gitignore` check

| Path | Bytes | SHA-256 (re-verified this pass; matches X15 §3.2) | Git state | Ignore rule |
|---|---:|---|---|---|
| `variant3d/assets/terrain/atlas/tile_index_atlas.png` | 179,912,941 | `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd` | **TRACKED** | **NONE** |
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` | 124,463,306 | `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` | **TRACKED** | **NONE** |
| `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000` | 90,000,000 | `019f0f9d7ea1430131189881db58e3f3fa138eb76209d643d53e698b73dd525f` | **TRACKED** | **NONE** |
| `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001` | 89,912,941 | `295a527ce8c402d8c8c80775538a6a0c0e6859fa94a758194cc096db0faba1be` | **TRACKED** | **NONE** |
| `variant3d/assets/terrain_new/patterns/family_index.json` | 55,507,231 | `177b06aa61f7b14de317accfa0fa722dbac9e19c2b8a2cdf7fc37a0f0928fab4` | untracked | **NONE** |
| hypothetical `variant3d/assets/terrain_new/atlas/tile_index_atlas.png` / `.../seasons/tile_index_atlas_winter.png` / `.../atlas_parts/*.partNNN` | — | — | absent | **NONE** |

**[O] `.gitignore` findings** (root `.gitignore`, the only relevant ignore file; `rustport\.gitignore` is Rust-only):
- No rule mentions `terrain_new`, `terrain/atlas`, `tile_index_atlas`, `*.partNNN`, `*.png` under assets, or LFS.
- The existing `*.part` rule matches only filenames ending in `.part`, **not** `.part000` / `.part001`.
- `git check-ignore -v` returned no output (NO RULE) for every path tested, including actual legacy large files and hypothetical future `terrain_new` atlas/part files.
- **[D]** Adding ignore rules will **not** untrack the four already-tracked legacy files; COORD must explicitly `git rm --cached` them (or configure Git LFS) if they are to leave the commit. This report does not perform that action.

**[O] Existing tool-side guard** (`build_terrain_new_atlas.py:459-495,945-962`): `licence_guard_record()` lists the three legacy transports as `uncommitted_or_lfs`, records `forbidden_output_hashes`, refuses `--hires-local` writes under `terrain_new`, refuses commit-tier writes outside `terrain_new`, and aborts if `--cell 1024` would reproduce the legacy atlas bytes. Dry-run is the default. **[I]** This is a tool guard, not a `.gitignore` guard.

**[D] Must stay uncommitted/LFS:** both >100 MB atlases and both split parts (the parts are a lossless byte split of the same summer art, per X15 §3.1). Safe to commit: compact `--cell 128` atlas + manifest, alpha/alphavert, derived JSON (including the 55 MB `family_index.json` if COORD accepts the size), tool source, validation logs.

---

## 5. Paste-ready `CREDITS.md` entry

**COORD action:** append the block below to **`variant3d/CREDITS.md` only**. Do **not** edit `app/CREDITS.md` (`app/` must stay byte-identical). No other CREDITS change is required for today's assets; the pre-existing DDS/BMP/OGG/LIB copies are already covered at `variant3d/CREDITS.md:7-34`.

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

---

## 6. Owner-facing HANDOFF statement — exactly what to add

**Placement:** `docs/terrain_swarm_2026-11-26/HANDOFF.md`, §0 ("Read this first") and/or §5 ("Explicit parity gaps"). Paste verbatim:

```markdown
**Private use / never redistribute (owner-facing, V49).** All Cossacks 3 material
used by the DONOR-FIRST terrain swarm was read in place from the owner's own
installation at `C:\Games\Cossacks 3`, read-only; no donor executable was run and
no donor byte was copied back into the install. The repository contains only
private-use copies and conversions for that owner on their own machine. Neither
the tracked donor copies (`app/assets/**`, `variant3d/assets/terrain/decals*`)
nor the new derived `variant3d/assets/terrain_new/**` JSON assets may be shared,
published, uploaded or redistributed. `app/` is byte-untouched. Visual donor
parity remains UNVERIFIED — no donor GPU A/B frame exists; all port behaviour is
PORT APPROXIMATION. See `variant3d/CREDITS.md`, `app/CREDITS.md` and
`docs/WAIVERS.md` ("Compliance statement").
```

**[O]** This is consistent with `docs/WAIVERS.md:57-64`, `app/CREDITS.md:1-5`, `variant3d/CREDITS.md:1-5` and the README licence block. **[D]** It makes no parity claim and asserts no gate result.

---

## 7. UNVERIFIED register

1. **[U]** Exhaustive list of every donor file read today by all 30 workers — only wired tool inputs, report evidence and re-hashed anchors were re-verified this pass.
2. **[U]** Final stability of the 780-file / 242,316,351 B snapshot — swarm writers were still active (mtimes up to 10:00:57); COORD must re-run the census before committing.
3. **[U]** Full byte-level scan of all 780 JSON outputs for embedded donor binary blobs — not performed (extension, hash-anchor and path-string checks only).
4. **[U]** Whether the other 930+ tracked `.dds`/`.ogg`/`.bmp`/`.lib` files are each verbatim donor — only five pairs hashed; the rest are inferred from documented families.
5. **[U]** Visual donor parity — no donor GPU A/B frame exists; `PORT APPROXIMATION` only.
6. **[U]** Whether COORD will strip the 714 absolute-path JSON files before commit; no file was edited by V49.
7. **[U]** Whether COORD will `git rm --cached` / LFS-track the four large legacy derived files; no git action taken by V49.
8. **[U]** Whether the missing root `terrain_new/manifest.json`, `atlas/**`, `masks/**` and `schemas/**` will be produced before integration; the A03/X15 schema is currently only partially satisfied.
9. **[U]** Whether `V29`'s stale HANDOFF snapshot (§2.2 "assets/terrain_new/** absent") will be corrected by COORD.

---

## 8. Open questions

1. **COORD:** append the §5 block to `variant3d/CREDITS.md` verbatim? (Do not touch `app/CREDITS.md`.)
2. **COORD:** strip `C:\Games\Cossacks 3` from the 714 derived JSON files before any commit, or accept a documented waiver? A03 §2.2.5 / X15 §2.1 currently prohibit it.
3. **COORD:** add `.gitignore` entries for `variant3d/assets/terrain_new/atlas/**`, `variant3d/assets/terrain_new/**/*.part[0-9]*`, and `git rm --cached` the four already-tracked large derived files (or move them to LFS)?
4. **COORD:** commit policy for the 55,507,231 B `patterns/family_index.json` — X15 classifies derived JSON as safe, but repo size should be an explicit decision.
5. **COORD:** update `HANDOFF.md` §0/§2.2 with the §7 correction and the §6 private-use statement; V29's snapshot is stale on `terrain_new`.
6. **Owner:** confirm that the verbatim tracked donor copies (936 DDS / 650 OGG / 29 BMP / 8 LIB) remain local-only — they are disclosed in CREDITS/WAIVERS but are still donor bytes in the repository.

---

## 9. Attestation and 5-line summary

**Attestation.** Read-only worker. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V49_licence_credits.md`). No source, shader, config, asset, test, result JSON, `.gitignore`, git index or Godot change. Donor path `C:\Games\Cossacks 3` was opened only for read-only hashing; no donor executable was run and no donor file was modified. Multiple passes were used on the `terrain_new` absence/presence contradiction and on every hash/path claim. **No donor parity claim.**

1. **[O/D] Contradiction resolved by four passes:** `terrain_new` was absent at audit start, then appeared mid-audit with 780 JSON files / 242,316,351 B (mtimes 09:58:40–10:00:57) — concurrent swarm writers, not a hash disagreement.
2. **[O] Donor read → derived written:** 710 `.pattern` + `pattern.lib` (sha `f7b421b1…`, re-verified) + 7 cfg files were read; output is 780 labelled JSON files carrying `visual_parity_claim:false` (780/780), with no atlas, masks or root manifest yet.
3. **[O] No new raw donor copy:** no `.tga/.osm/.oss/.pattern/.map`/donor `.exe` was written; five pre-existing tracked verbatim donor copies (DDS/LIB/BMP/OGG) matched donor hashes exactly and pre-date today's port.
4. **[O] Compliance gaps:** 714 derived JSON files embed the absolute donor install path (forbidden by A03/X15 before commit), and `.gitignore` covers none of the four already-tracked large derived files (179 MB / 124 MB / 90 MB + 89.9 MB).
5. **[O/D] Actions for COORD:** append the paste-ready `variant3d/CREDITS.md` block (§5), add the private-use/never-redistribute HANDOFF statement (§6), strip absolute paths, and fix the ignore/LFS policy — all with parity still UNVERIFIED.

*End of V49 report.*
