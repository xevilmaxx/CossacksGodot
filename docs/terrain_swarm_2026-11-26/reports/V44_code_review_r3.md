---
id: V44
ticket: "TERRAIN-SWARM-2026-11-26 / V44 — round-3 review of the three MAJOR V28 findings"
agent: "V44 (review-only subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__REVIEW_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_GODOT_JOB__NO_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/V44_code_review_r3.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V44_code_review_r3.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary was executed, no donor GPU A/B frame was used, no Godot process, gate, runner job or capture was run. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,122-130). Every port consequence below is PORT APPROXIMATION. This review makes NO parity claim and NO gate PASS claim."
scope_guard: "Read-only file reads, grep/Select-String, git status/git diff, PowerShell Test-Path/Get-FileHash, and one read-only Python `decode_donor_cfg.py --check` (dry-run default: --out absent, zero files written) were used. No source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or app/ byte was changed."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V44 — round-3 code review (focused on V28's three MAJOR findings)

## 1. Executive summary

1. **[O]/[D] Two of V28's three MAJOR findings are CLOSED; one remains OPEN.** F-03 (`decode_donor_cfg.py --check` permanently red) is **PASS** — C01 now expects 19, MP-1 is a documented non-fatal exception, and a read-only `--check` exits 0 with `7/7 hashes, 19/19 count checks, determinism PASS`. F-02 (`DONOR_UNITS=160` prop doubling) is **PASS** — no executable `DONOR_UNITS`/`cell_scale` remains; props use 1:1 donor cells and `TILE_M` only for world placement. F-01 (I03 emitting I02-owned outputs) is **FAIL / MAJOR** — `decode_pattern_lib.py:1046,1048-1049` still writes `family_index.json` and `families/<family>.json` into the I02-owned `patterns/` root (`V11_ownership_ledger.md:123-124`). No ownership amendment landed (V36 `:132,147` still lists it as C7 HIGH).
2. **[O] The four remaining requested checks are PASS.** I07 RNG is key1-only with X21 constants/f32 emulation and a labelled XU5 hook (`terrain_donor_gen.gd:90-95,311-348,580-606`); I07 blend implements the D05 F4 / X13 formulas verbatim (`:1547-1585`, `:1607+`). I06's `TILE_M` is donor-grounded horizontally and explicitly leaves stored height units `[U]` (`terrain_donor_data.gd:17-19,38-39,206-208`). The I11 seam is additive/legacy-default with both `make_world3d()` sites guarded and both `COORD-I11` backups present at the exact V11 baseline hashes. `app/**` is byte-untouched.
3. **[O] Forbidden-pattern scan is clean.** V33 §4's 9-file top-8 scan re-run at this review: `FILES=9 HITS=4`, and all four hits are benign prose/telemetry (no executable noise/dither, face promotion, HEIGHT_SCALE fudge, `W/160`, `B>58`, `rgb*a`, 6-pass/3×3, or parity claim). `visual_parity_claim=false` is universal in the fresh modules.
4. **[O] ABSENT entries are worker-running states, not failures.** `V38_code_review_r2.md` is ABSENT; N6 `build_terrain_new_manifest.py`, N7 `validate_terrain_new.py`, N10 `terrain_donor_tiles.gd`, the real `inbox/qa/terrain_qa_report.json` and `inbox/qa/captures/` are still ABSENT (only three `*.PENDING` placeholders exist). By contrast V37's shader decision (b) **was** applied: canonical `variant3d/shaders/terrain_donor_shader.gdshader` now exists and the alias is gone.
5. **[U] No parity claim, no gate result.** This is a static read plus one read-only Python decoder check. Nothing here certifies Godot parse, determinism replay, capture, selftest 29/29, uitest 17/17 or `assert_clean`; parity remains UNVERIFIED / PORT APPROXIMATION.

> [!IMPORTANT]
> Labels: **[O]** literal read/output; **[D]** deterministic consequence of [O]; **[I]** inference; **[U]** UNVERIFIED; **PORT APPROXIMATION** for port-authored substitutes. All file:line anchors are from the working tree at the read time below; concurrent landing can shift them. Re-read before acting.

---

## 2. Multiple-pass log (CHARTER.md:85-93)

| Pass | Instrument(s) | Result / effect on verdict |
|---|---|---|
| P1 | `glob` for `V33*`/`V38*` | Returned no files for either — appeared to confirm both ABSENT. |
| P2 | PowerShell `Test-Path` on four exact doc paths | **Contradiction resolved:** `reports/V33_do_not_do_checklist.md` EXISTS; `V38_code_review_r2.md` is genuinely ABSENT. P1 was a glob artefact; V33 read in full. |
| P3 | `grep` on `terrain_donor_props.gd` for `DONOR_UNITS|cell_scale|160` | Hit at `:620` suggested the V28 MAJOR was still live. |
| P4 | Fresh `Select-String` (same file) + full `read` of `:1-120` and `:590-659` + `Get-Item LastWriteTimeUtc` | **Contradiction resolved:** `:620` is only a comment ("no W/160, no x2"), `:622-626` uses raw cells; only remaining tokens are comments at `:24,:88` and a field-name skip-list at `:564`. P3 was a stale/racy grep snapshot — **not** a defect. |
| P5 | Code read of `decode_donor_cfg.py:420-442,679-702,805-824` | C01 = 19; MP-1 documented; `ok_count` compares pass/total only. |
| P6 | Read-only `python ... decode_donor_cfg.py --game "C:\Games\Cossacks 3" --check` (dry-run default, no `--out`) | `check: hashes PASS counts PASS determinism PASS`, `summary: 7/7 hashes, 19/19 count checks`, `NOTE MP-1`, determinism PASS on all three payloads. |
| P7 | Second identical run with output suppressed, `EXIT=$LASTEXITCODE` | `EXIT=0` — exit code independently confirmed; no files written either run. |
| P8 | `git diff -- main.gd world3d.gd` + `Select-String` seam symbols + `Get-FileHash` on both `.bak-COORD-I11` | Diff is additive except the one sanctioned ternary at `world3d.gd:624`; backup hashes equal V11 §2 baseline exactly. |
| P9 | `git status --short`, `git status --short -- app/`, `git diff --exit-code -- app/` (exit 0) | Two instruments agree: no tracked or untracked `app/**` change. |
| P10 | V33 §4 top-8 PowerShell scan re-run over the 9 fresh files, skipping `#`/`//` lines | `FILES=9 HITS=4`; all four classified benign; zero executable hits. |
| P11 | `Test-Path` over N6/N7/N10/N13/N18/N19 and shader alias | Canonical shader present, alias absent; N6/N7/N10/N18/N19 absent. |

**[O] No anomaly was accepted after a single reading.** The two apparent blockers (V33 absence, props `DONOR_UNITS` at `:620`) were overturned by a second instrument and are explicitly **not** reported as defects.

---

## 3. Evidence table

| ID | Source (file:line / command) | Observation | Label | Consequence |
|---|---|---|---|---|
| E01 | `decode_donor_cfg.py:432-442` | `add("C01", ..., 19, ...)` with four-pass agreement and MP-1 note; no key invented | [O] | F-03 root cause removed in code |
| E02 | `decode_donor_cfg.py:679-702`, `:834` | `documented_exceptions` MP-1 = 20-vs-19 provenance; printed as `NOTE`, printed `check_basis` line | [O] | MP-1 is non-fatal, not a gating FAIL |
| E03 | `decode_donor_cfg.py:815-824,849-851`; read-only `--check` runs (P6/P7) | `ok_hash && ok_count && ok_det`; exit 0; `7/7`, `19/19`, determinism PASS | [O]/[D] | Finding 1 PASS |
| E04 | `decode_donor_cfg.py:53` | Still emits `"structure": "1 section, 20 flat keys (:1-21)"` | [O] | Residual MINOR (V37 E7/R2): stale manifest label |
| E05 | `decode_pattern_lib.py:40,1040-1049,781,794,1098-1106` | Default `--out .../terrain_new/patterns`; docs dict contains `family_index.json` plus `families/*.json`; write loop joins `out` with each key | [O] | Finding 2 FAIL — files really land under `patterns/` |
| E06 | `V11_ownership_ledger.md:123-124`; `V36_integration_checklist.md:132,147`; `decode_donor_pattern.py` (no `family_index`/`families` matches) | G3/G4 are I02-owned; V36 still rates the collision C7 HIGH; I02 emits neither | [O] | No ownership amendment landed; F-01 unresolved |
| E07 | `terrain_donor_props.gd:22-32,88,618-626`; fresh `Select-String` (P4) | V08 cell-space contract; scaling removed; `dx/dz = roundf(rec["px"/"pz"])`, world position via `TILE_M` only | [O] | Finding 3 PASS; V33's live D14 hit is gone |
| E08 | `terrain_donor_props.gd:564` | `"donor_units"` appears only in a field-name skip-list for feed parsing | [O] | Benign, not a scale operation |
| E09 | `terrain_donor_gen.gd:90-95,213-218,311-324,326-348,580-606` | X21 LCG constants (`0xFC0D`, `0x3C6EF35F`, `2^32`), key0 discard/labelled NO-OP, key1-only `s = k1 & LCG_U32`, f32 round-trip, three streams + Delphi, key1_mode ledger | [O] | Finding 4a PASS (static); XU5 signed edge case remains `[U]` with a hook |
| E10 | `terrain_donor_gen.gd:40-48,1547-1585,1607+` | D05 F4 formulas: `(g-hmin)*scale+hmin`, `g*scale` for rep_water, `base_h+g+hoff`, `(base_h-h0)*terrain_scale+g+hoff` + second read `+h1`; Min is pivot, Max unused; X13 vector discrepancy quoted | [O] | Finding 4b PASS (static); smooth buffer mode / x87 / row sign remain `[U]` |
| E11 | `terrain_donor_data.gd:17-19,38-39,206-208,605` | `"DONOR-GROUNDED horizontally ... stored height units remain UNVERIFIED"`; `height_unit: "[U] raw float32; no HEIGHT_SCALE multiplier applied"` | [O] | Finding 5 PASS |
| E12 | `main.gd:125,189-191,593-594,1112-1113`; `world3d.gd:118,144-145,220-224,624,645,706-707` | default `"legacy"`, unknown→legacy, both call sites guarded by `world != null and world.has_method(...)`, lock after bind, A/B stats keys | [O] | Finding 6 PASS (additive seam, one sanctioned ternary) |
| E13 | `git diff -- main.gd world3d.gd`; `Get-FileHash` backups | Only one deleted line (the sanctioned ternary); `main.gd.bak-COORD-I11` = `3859B605…`, `world3d.gd.bak-COORD-I11` = `44EE96C0…` — exact V11 §2 baselines | [O]/[D] | Backups verified, not merely present |
| E14 | `git status --short`; `git status --short -- app/`; `git diff --exit-code -- app/` → 0 | No app entry in status; no diff | [O] | Finding 7 PASS |
| E15 | V33 §4 scan re-run (P10); `terrain_donor_mesh.gd:42,89,150,660,678,746-748`; all fresh modules' parity guards | `FILES=9 HITS=4`, all benign; `HEIGHT_SCALE=1.0` labelled contract; relief cells forced face 0; `visual_parity_claim=false` everywhere | [O] | Finding 8 PASS |
| E16 | `terrain_qa_harness.py:784`; `decode_pattern_lib.py:892-899,1057-1061`; `build_terrain_new_atlas.py:854-859` | Harness still hardcodes `banned_phrases_absent: True`; I03 `observed=True` cosmetic but `condition` is the real predicate; atlas tautology removed | [O] | Residual MINOR telemetry only; no gate was lowered |
| E17 | `Test-Path` (P11); `inbox/qa/*.PENDING` three files | N6/N7/N10, real N18 report and N19 captures ABSENT; placeholders explicitly `NOT_RUN`, zero gates; canonical shader present | [O] | ABSENT = worker running; placeholder is not a green result |

---

## 4. Finding-by-finding verdicts

### R3-1 — `decode_donor_cfg.py --check` against 19 observed keys — **PASS** (MAJOR F-03 CLOSED)

- **Evidence:** `decode_donor_cfg.py:432-442` (C01 `expected=19`, four passes), `:679-702` (MP-1 documented exception), `:815-824` (exit logic), `:834` (basis print); read-only runs P6/P7: `check: hashes PASS counts PASS determinism PASS`, `summary: 7/7 hashes, 19/19 count checks`, `NOTE MP-1`, `EXIT=0`.
- **Severity:** MAJOR was at stake; now closed. Residual **MINOR** at `:53` (`"20 flat keys"` stale label) — the emitted manifest still carries the F03 summary error that V37 `:101-105` asked to correct.
- **Concrete fix (residual only):** change `:53` to `"1 section, 19 flat keys (:2-20)"`; leave C01=19 and MP-1 untouched. Do **not** raise the expectation to 20 or delete the exception — that would invent a key (`CHARTER.md:83-84`; `V37:202-204`).

### R3-2 — `decode_pattern_lib.py` no longer emits I02-owned outputs — **FAIL** (MAJOR, HIGH)

- **Evidence:** `decode_pattern_lib.py:1040-1049` includes `"family_index.json"` at `:1046` and appends `family_docs` keyed `"families/<name>.json"` (`:781`, `:794`, `:1048-1049`); `:40` defaults `--out` to `variant3d/assets/terrain_new/patterns`; `:1098-1106` writes every key under that root. V11 G3/G4 (`V11_ownership_ledger.md:123-124`) assign both to **I02**; V36 `:132,147` still rates C7 HIGH and uncoupled; `decode_donor_pattern.py` emits neither (grep: no matches).
- **Severity:** **MAJOR / HIGH** — two writers, one emitted path set; nondeterministic clobber under `--write` and a broken one-owner-per-file invariant. No evidence of a COORD ownership amendment (V33/V34/V36/V37 contain none).
- **Concrete fix:** remove `family_index.json` and the `family_docs` loop from the `docs` payload at `:1040-1049` (retain I03's G5 `pattern_lib_index.json` plus uniquely named `line_byte_offsets.json`, `heightfield_census.json`, `object_census.json`, `validation.json`), **or** have COORD formally amend V11 G3/G4 to I03 and forbid I02 emission in the same commit. Add a write-collision guard to both decoders that refuses to write a path already claimed by another owner. Do not silently edit the ledger and the tool at once (V28 Q1).

### R3-3 — `terrain_donor_props.gd` no `DONOR_UNITS=160` doubling — **PASS** (MAJOR F-02 CLOSED)

- **Evidence:** `terrain_donor_props.gd:22-32` states the V08 1:1 cell contract; `:88` records deliberate removal; `:620-626` computes `dx = roundf(rec["px"])`, `dz = roundf(rec["pz"])` and world X/Z from `(cell + 0.5 - dim*0.5) * TILE_M` — `TILE_M` is horizontal metres-per-cell only. Fresh `Select-String` (P4) finds `DONOR_UNITS` only in comments `:24,:88,:620` and `"donor_units"` as a parse skip-list key at `:564`.
- **Multiple-pass note:** the first `grep` reported a hit at `:620`; the second instrument and a full read showed it is a comment. V33's scan-time live hits at `:76`/`:608` (V33 `:19,152-154,161`) are gone — the file was edited after that ticket.
- **Severity:** MAJOR closed; no residual. Integer sampling of fractional donor cells remains an explicit PORT APPROX (`:32`).
- **Concrete fix:** none. Preserve the 1:1 placement; do not reintroduce `W/160` or a second silhouette scale.

### R3-4 — I07 RNG key1-only/X21 and blend D05/X13 — **PASS** (static)

- **RNG [O]:** `terrain_donor_gen.gd:90-95` pins X21 constants (`LCG_MUL=0xFC0D`, `LCG_ADD=0x3C6EF35F`, `LCG_U32`, `LCG_DIV=2^32`, separate Delphi LCG); `:213-218` records X21's key0-discard correction; `:311-324` re-seeds with `s = k & LCG_U32` and `s = k1 & LCG_U32` while key0 is ledger-only; `:326-348` advances `s=(s*mul+add)&LCG_U32`, returns explicit f32 (`_f32`), and records every draw; `:580-606` implements the stage ledger with `"key_mode": "key1_only"` and X21 §6.2 version-aware keys. This matches `X21_rng_vectors.md:40-57,177-186,272-279,415-419`. No `mix64` anywhere.
- **Blend [O]:** `:1547-1553` reads Min/Offset/Scale/terrain_scale/replace flags and bilinear base; `:1562-1566` treats Min as pivot, never clamp, Max unused; `:1577-1585` implements the three D05 F4 branches including the two-read Smooth term; `:1607+` implements the 8-neighbour smooth post-pass. `:40-48` explicitly quotes X13 vector `REP-hil1-01` (`0x4074F076` vs brief `0x40A5B75B`) and refuses the simplified brief formula.
- **Severity:** none found. **[U] residuals are correctly labelled:** XU5 signed key0 edge case with hook (`:218`, X21 §9), smooth buffer mode and x87 precision (`:222-231`), row sign/rotation rounding (`:233-235`), random-scale LCG feed (`:255-257`).
- **Concrete fix:** none for the inspected code. At QA, replay the X21/X13 vectors through the live module before any determinism claim; V44 did not execute Godot or a vector replay.

### R3-5 — I06 `TILE_M` donor-grounded, height units UNVERIFIED — **PASS**

- **Evidence:** `terrain_donor_data.gd:17-19` ("DONOR-GROUNDED horizontally (dmscript.global:170-173, 2m/cell); stored height units remain UNVERIFIED; row sign UNVERIFIED"), `:38-39` (`TILE_M=2.0` + `TILE_M_LABEL`), `:206-208` (meta `tile_m`, `tile_m_label`, `height_unit: "[U] raw float32; no HEIGHT_SCALE multiplier applied"`), `:605` (same label in stats).
- **Severity:** none. No metre assertion attaches to the height float; no HEIGHT_SCALE value was invented.
- **Concrete fix:** none. Keep the horizontal/vertical distinction when I08/I09 consume `TILE_M` — world placement only, never a generator distance multiplier.

### R3-6 — I11 seam additive, legacy default, both sites guarded, backups present — **PASS**

- **Evidence:** `git diff` shows only insertions plus **one** sanctioned line replacement — `world3d.gd:624` `terrain = _instantiate(TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT)` (spec/12 §12.1's ternary). Default `legacy` at `main.gd:125` and `world3d.gd:144`; coercion of unknown config values at `main.gd:189-191`; setter with post-bind lock at `world3d.gd:220-224,645`; guards at **both** `make_world3d()` sites `main.gd:593-594` and `main.gd:1112-1113`; A/B telemetry `world3d.gd:706-707`. Backups `inbox/backup/main.gd.bak-COORD-I11` (`3859B605…`) and `world3d.gd.bak-COORD-I11` (`44EE96C0…`) match V11 §2 baselines exactly (E13).
- **Severity:** none. The seam is opt-in; no legacy assertion, threshold or gate was removed.
- **Concrete fix:** none. COORD should still re-run V11 §8 verification commands before treating the seam as accepted, and require `missing_modules` empty before any opt-in capture (V28 §6.3).

### R3-7 — no `app/**` change — **PASS**

- **Evidence:** `git status --short` shows no `app/` entry (tracked or untracked); `git status --short -- app/` empty; `git diff --exit-code -- app/` → exit 0 (P9).
- **Severity:** none. **Concrete fix:** none. Keep `app/**` frozen (V11 §6 rule 1).

### R3-8 — forbidden-pattern scan clean — **PASS** (static)

- **Evidence:** V33 §4 scan re-run (P10): `FILES=9 HITS=4`; hits are `terrain_donor_gen.gd:677` (telemetry string asserting no scaling), `terrain_donor_props.gd:564` (field-name skip-list), `decode_donor_cfg.py:23` and `decode_donor_masks.py:14` (contradiction-preserving docstrings). No executable hit for dither/noise, face promotion/rock thresholds, non-1.0 HEIGHT_SCALE, `W/160`, `B>58`, `rgb*a`, 6-pass/3×3, mix64, or parity claim. `terrain_donor_mesh.gd:42,150,746-748` multiplies by the labelled `HEIGHT_SCALE=1.0` (V28 F-09 MINOR, explicitly not a fudge value); relief cells still forced face 0 (`:660`).
- **Severity:** none for the V33/V28 forbidden set. **Residual MINOR telemetry (not a forbidden construct, no gate lowered):** `terrain_qa_harness.py:784` still hardcodes `banned_phrases_absent: True`; `decode_pattern_lib.py:1057-1061` still reports a literal `observed=True` although `add()`'s `condition` at `:892-899` is the real computed predicate, so its PASS/FAIL is no longer faked; `build_terrain_new_atlas.py:854-859` tautology is **gone**.
- **Concrete fix (residual only):** compute `banned_phrases_absent` from scanned emitted gate rows and pass the real predicate as `observed` in the two self-checks. Do not change any shipped gate threshold while doing so.

### ABSENT entries (worker running — not failures)

| Path | State | Note |
|---|---|---|
| `docs/terrain_swarm_2026-11-26/reports/V38_code_review_r2.md` | **ABSENT** | Two exact `Test-Path` checks (P2); glob artefact ruled out. No R2 verdict available to V44. |
| `variant3d/tools/build_terrain_new_manifest.py` (N6) | **ABSENT** | Worker still running; do not infer a defect. |
| `variant3d/tools/validate_terrain_new.py` (N7) | **ABSENT** | Worker still running. |
| `variant3d/scripts/terrain_donor_tiles.gd` (N10) | **ABSENT** | I07 secondary module still pending; composer degradation applies. |
| `inbox/qa/terrain_qa_report.json` (N18), `inbox/qa/captures/` (N19) | **ABSENT** | Only `PENDING_N19_captures.md`, `PENDING_N7_validate_terrain_new.md`, `terrain_qa_report.json.PENDING` exist; the latter explicitly declares `NOT_RUN`, zero gates, `parity.status=UNVERIFIED`. It is **not** a green result. |
| `variant3d/shaders/terrain_donor_shader.gdshader` (N13) | **PRESENT** | V37 decision (b) applied: canonical name exists, A06 alias `terrain_donor.gdshader` absent; composer binds canonical first (`terrain_donor_world.gd:35,36,151`). |

---

## 5. Remaining blockers (COORD-owned)

1. **B1 — MAJOR F-01 still open.** I03 writes `patterns/family_index.json` and `patterns/families/*.json` owned by I02 (`decode_pattern_lib.py:1046,1048-1049`; V11 `:123-124`; V36 C7). No `--write` to the shared root should occur until one owner is chosen and a collision guard exists.
2. **B2 — Stage A′ invalidity.** No N7 `validate_terrain_new.py`, no real N18 report, no N19 captures; the `.PENDING` fixture is fail-closed (`terrain_qa_report.json.PENDING:2-35`). Gate A′ cannot be certified from these artefacts.
3. **B3 — Parse-before-switch.** N10 tiles absent; composer `terrain_donor_world.gd:187-188` degrades gracefully, so a `"donor"` opt-in could compose with missing modules. Require `missing_modules` empty before capture.
4. **B4 — Residual stale label/telemetry.** `decode_donor_cfg.py:53` still says "20 flat keys"; `terrain_qa_harness.py:784` still hardcodes its banned-phrase boolean. Neither lowers a gate, but both pollute the evidence trail.
5. **B5 — V38 absent.** No round-2 review landed; R3 cannot rely on an R2 verdict. Any R2 findings that land later supersede the relevant PASS verdicts here.

## 6. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | Two decoders clobber G3/G4 outputs on `--write` | [D] HIGH | B1; one writer per emitted path, collision guard in both tools |
| R2 | Someone "fixes" the missing 20th key to match F03's summary | [D] HIGH | E01-E03 prove 19; MP-1 must stay non-fatal; no key invented (`CHARTER.md:83-84`) |
| R3 | V33's old live `DONOR_UNITS` hit is re-read as current and triggers an unnecessary revert | [O] MEDIUM | P3/P4: stale grep, fresh read and scan all clean; cite fresh output |
| R4 | Static key1-only/D05-X13 reads are mistaken for runtime parity | [U]/PORT APPROX HIGH | No Godot, no vector replay, no donor frame; parity UNVERIFIED |
| R5 | Hardcoded telemetry booleans create false confidence in QA output | [O] MEDIUM | E16; compute real predicates before trusting any harness "PASS" |
| R6 | Opt-in "donor" mode silently composes with missing N10 | [D] HIGH | B3; require `missing_modules` empty before capture |
| R7 | Line numbers drift as workers land | [U] MEDIUM | P3/P4 showed a live file changing mid-review; re-read anchors before acting |
| R8 | A visual improvement is misread as donor parity | [U]/PORT APPROX HIGH | `CHARTER.md:43-44,122-130`; no donor GPU A/B frame exists |

## 7. Open questions for COORD

1. **Q1.** Who owns `patterns/family_index.json` and `patterns/families/*.json` after F-01 — I02 per V11 G3/G4, or I03 as current emitter? Amend the ledger **or** the tool, not both silently (V28 Q1, V36 Q3).
2. **Q2.** Approve the one-line `decode_donor_cfg.py:53` label fix to 19, keeping C01=19 and MP-1 as non-fatal provenance (V37 §2)?
3. **Q3.** When N7/N10/N18/N19 land, will V44 (or a successor) re-run this same eight-item check against the new snapshot?
4. **Q4.** Should the residual hardcoded self-check booleans (`terrain_qa_harness.py:784`, `decode_pattern_lib.py:1057-1061`) be repaired before any harness output is cited, or recorded as advisory UNVERIFIED?
5. **Q5.** Is the canonical shader rename (V37 decision b) now final, i.e. may the composer's inert `DONOR_SHADER_ALIAS` branch (`terrain_donor_world.gd:36,151`) be retired in a separate COORD commit (V37 Q3)?
6. **Q6.** Should V38 R2 be re-dispatched, given its ABSENT state blocks cross-checking of the full I07/I09/I11/I12 bodies?

## 8. Handoff summary (5 lines)

1. **Verdict:** two of three MAJOR V28 findings CLOSED — F-03 (`--check` 19/19, exit 0, MP-1 non-fatal) and F-02 (no `DONOR_UNITS` scaling); **F-01 remains FAIL/MAJOR** — `decode_pattern_lib.py:1046,1048-1049` still emits I02-owned `patterns/family_index.json` / `families/*.json`.
2. **Other requested checks:** I07 key1-only X21 RNG + D05/X13 blend PASS (static, `[U]` residuals labelled); I06 TILE_M donor-grounded with height units UNVERIFIED PASS; I11 seam PASS (legacy default, both sites guarded, backups hash-match V11); `app/**` untouched PASS.
3. **Forbidden scan:** clean — `FILES=9 HITS=4`, all benign prose/telemetry; no executable noise, face promotion, HEIGHT_SCALE fudge, `W/160`, parity claim or lowered gate; residual cosmetic self-check booleans noted.
4. **ABSENT (worker running, not failures):** V38 review, N6/N7/N10, real N18 report and N19 captures; canonical shader is present and alias retired.
5. **Guards:** 11 multi-pass readings recorded; one read-only Python `--check` (no writes); no Godot, gate, capture, donor execution or repo edit beyond this report; **no donor parity claim** — parity stays UNVERIFIED / PORT APPROXIMATION.

---

*End of V44 report. Exactly one repo file written; no source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or `app/` state changed.*
