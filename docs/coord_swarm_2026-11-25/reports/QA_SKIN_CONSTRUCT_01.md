---
id: QA-SKIN-CONSTRUCT-01
title: "QA-SKIN-CONSTRUCT-01 — verify the `construct` skin export change after its owner lands"
date: 2026-11-25
agent: QA-SKIN-CONSTRUCT-01 (read-only QA subagent)
status: DELIVERED__CODE_LEVEL_PASS__ASSET_REGEN_PENDING__NO_VISUAL_PASS__NO_PARITY_CLAIM
scope: "Read-only QA. No code, config, asset, test, scene, git or runner-job change; this report is the only file written. Donor read-only bytes/latin-1 only; no donor binary executed, unpacked or copied. In-memory Python 3.14 compile/exec probe (no pyc written to repo, no converter invocation, no Godot)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
targets:
  - "variant3d/tools/convert_skins.py"
  - "inbox/backup/convert_skins.py.bak-BUILDSKIN01"
  - "docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md"
  - "docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md"
  - "variant3d/assets/models/skin/index.json"
  - "variant3d/assets/models/skin/peasant.json"
  - "C:\\Games\\Cossacks 3\\data\\animations\\aaf\\peaukr.aaf (READ-ONLY)"
output: "docs/coord_swarm_2026-11-25/reports/QA_SKIN_CONSTRUCT_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
governing_rule: "Cite donor path:line; separate observed / derived / inferred / UNVERIFIED; never claim donor parity from data-level evidence (DANIM_01 frontmatter :12; BUILD_ANIM_DIAG_01 frontmatter :12; BUILD_SKIN_01 frontmatter :12)."
verdict: "CODE-LEVEL PASS, EXPORT-LEVEL NOT YET PASS. The landed change is additive: `construct` is appended once to `DEFAULT_ACTIONS`, syntax compiles, no other action or function changed, and `sample_frames(186,198,6)` derives `[186,188,191,193,196,198]`. The GENERATED skin assets have NOT been regenerated: `index.json` still requests 7 actions and `peasant.json` has no `construct` action and none of frames 186..198. A regeneration + capture is still required; there is NO visual PASS and NO donor-parity claim."
---

# QA-SKIN-CONSTRUCT-01 — verify the `construct` skin export change

## 0. Label key and discipline

- **observed** — literal file/byte content read in this pass (code, backup, reports, donor line, generated JSON, diff output).
- **derived** — deterministic comparison or computation over observed content (AST equality, tuple/set comparison, hash, `sample_frames` result).
- **inferred** — interpretation with an explicit caveat; not a literal read by this QA.
- **UNVERIFIED** — cannot be settled from read-only evidence; carried forward, never promoted.

Only `docs/coord_swarm_2026-11-25/reports/QA_SKIN_CONSTRUCT_01.md` was written. **No generated skin JSON, code, config, test, scene or git state was changed; no converter was run against `--out`; no runner job, Godot, Blender or donor binary was executed.** Donor access was a read-only byte read of one `.aaf` file.

---

## 1. Sources

All paths are relative to the repo root unless marked donor/absolute.

| # | Source | Role in this verification |
|---|---|---|
| S1 | `variant3d/tools/convert_skins.py` (read in full, 343 lines) | Code under test: `DEFAULT_ACTIONS` `:69-81`, `read_aaf` `:126-145`, `sample_frames` `:148-157`, `read_oss` `:89-123`, `skin_at` `:170-183`, `convert_unit` `:195-276`, `main` `:279-339` |
| S2 | `inbox/backup/convert_skins.py.bak-BUILDSKIN01` (read in full, 335 lines) | Pre-edit baseline; `DEFAULT_ACTIONS` `:69-74` |
| S3 | `git diff --no-index S2 S1` and `git status --short` | Change-scope and landed-state evidence |
| S4 | `docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md` (177 lines) | Owner's landed report; frontmatter `:1-14`, before→after `:52-86`, backup `:88-95`, static validation `:96-108`, regeneration hand-off `:110-127`, UNVERIFIED labels `:129-145` |
| S5 | `docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md` (324 lines) | Root cause and expected frames: `:153-169` (no `construct` in shipped skins), `:212` (fix recipe; `[186,188,191,193,196,198]`), `:239,244-245` (discriminator) |
| S6 | Donor `data/animations/aaf/peaukr.aaf:17` (read-only bytes, CRLF split, latin-1 decode) | Donor truth `"construct",186,198,morph` |
| S7 | `variant3d/assets/models/skin/index.json` (line 1, targeted fields) | Generated requested action set / peasant entry — currently old export |
| S8 | `variant3d/assets/models/skin/peasant.json` (line 1, targeted fields) | Generated per-sid action table and frame union — currently old export |
| S9 | In-memory Python 3.14 probe: `compile()`, `ast.parse`/`ast.dump`, `exec(compile(...))` in an isolated namespace, `hashlib`, `json` | Syntax, AST equality, action tuple, sampled frames, hashes — no file writes |

**Timing note (observed):** `BUILD_SKIN_01.md` was absent on this QA's first directory scan and present on the subsequent `git status` scan. It is treated as landed at the time it was read; no claim is made about the exact instant of landing.

Not re-read in this pass: `anim3d.gd`, `world3d_entities.gd` (current runtime state is carried from S5, not independently re-measured). No visual capture was available or run.

---

## 2. Verification table

| # | Check | Method | Result | Label | Evidence |
|---|---|---|---|---|---|
| V1 | Owner change landed | `git status --short`: `M variant3d/tools/convert_skins.py`; `?? .../reports/BUILD_SKIN_01.md`; report read in full | **YES** — code and report both present when read | observed | S3, S4 |
| V2 | Diff scope vs backup | `git diff --no-index S2 S1` | Single hunk `@@ -69,8 +69,16 @@`: 8 added citation-comment lines + one appended tuple member. No other hunk. | observed | S3 |
| V3 | Functions / other top-level values unchanged | Compare `ast.dump()` of every top-level function and assignment, S1 vs S2 | Only `assign:DEFAULT_ACTIONS` differs. `read_oss`, `read_aaf`, `sample_frames`, `qmat`, `skin_at`, `r6`, `convert_unit`, `main` and all other assignments are AST-identical. | derived | S9 |
| V4 | Requested action table value | `exec(compile(S1))` in an isolated namespace (no pyc) | `('idle','idle0','walk','walk0','death','attack0','attack1','construct')` | observed | S9; S1 `:80-81` |
| V5 | No other action changed / `construct` added exactly once | Compare V4 tuple to S2's 7-tuple; count occurrences | Original seven keep order and values; `construct` appears exactly once, as the last member. `frames_per_action` default still `6` (`:286`), `SCHEMA == "c3_skin_v1"` (`:82`). | derived | S9; S1 `:82,286`; S2 `:72-74` |
| V6 | Syntax compiles | `compile(cs, path, "exec")` under Python 3.14, in memory | **PASS**, no `SyntaxError`. No `__pycache__` written by this probe. | observed + derived | S9 |
| V7 | Donor action range | Read `peaukr.aaf` bytes read-only, split on CRLF, line 17 latin-1 decoded | `"construct",186,198,morph` → inclusive **186..198** = 13 frames; @30 fps (`.oss` header, S5 `:75`) = 0.433 s | observed + derived | S6; S1 `:72-79`; S4 `:35` |
| V8 | No hard-coded range in the tool | Code read: `read_aaf` parses name/first/last/kind and line number per unit's AAF; `convert_unit` selects by name and skips absent names | Confirmed: no `186`/`198` literal in executable code (only in the added citation comment). `first`, `last`, `donor` citation remain per-sid derived. | observed | S1 `:118-145,208-227`; S4 `:73-86` |
| V9 | Would-be exported frame set | `sample_frames(186, 198, 6)` from the loaded module | `[186, 188, 191, 193, 196, 198]` — matches the exact expected list in S5 `:212,239,244` | derived | S9; S1 `:148-157` |
| V10 | Backup integrity | SHA-256 of S2 bytes | `BC0986FBE32553EA315DE87D3BF414F9DB9A809F7CFBCE278C5C4F8BFC0848EE` — matches S4 §4 claim. Current S1 hash `AB5193CD02164B85077D66B0A6E1F320666BFD6B3BAE2A34DD3835CB505CFF2F`. | observed + derived | S9; S4 `:94` |
| V11 | **Generated** action table (`index.json`) contains `construct` | Targeted JSON field read | **NO.** `actions_requested = ['idle','idle0','walk','walk0','death','attack0','attack1']`; `frames_per_action = 6`; peasant entry actions = `{idle, idle0, walk, death, attack0}`. | observed | S7 |
| V12 | **Generated** `peasant.json` contains `construct` with frames 186..198 | Targeted JSON field read | **NO.** `actions` keys = `['attack0','death','idle','idle0','walk']`; `frames = [1,5,9,12,16,20,64,74,84,93,103,113,115,122,129,135,142,149,237,240,244,247,251,254]` — no 186..198. `construct` absent. | observed | S8 |
| V13 | Visual / rendered build pose | No capture, no runtime probe | **UNVERIFIED** — not assessed in this pass | UNVERIFIED | S5 §6 (recipe only); S4 §7 |

**Reading of V4/V9 vs V11/V12 (important):** the **code-level requested action table** passes (V4, V5, V9), but the **generated exported action table** does not yet contain `construct` (V11, V12). V9 is a derived prediction of what the converter *would* emit after regeneration; it is **not** evidence that the shipped asset contains those frames. No export-level PASS is claimed by this QA.

**No parity claim.** All frame/donor findings are data-level. Labels `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = "UNVERIFIED"` remain as generated (S1 `:61,246`, S7/S8 line 1).

---

## 3. Remaining work (still required; none done by this QA)

1. **Regenerate the skin assets — blocking.** This check explicitly did **not** regenerate generated skin JSON/assets. Offline, read-only-donor command from S4 §6 / S1 `:46-50`:
   `python variant3d/tools/convert_skins.py --game "C:\Games\Cossacks 3" --manifest variant3d/assets/models/manifest.json --out variant3d/assets/models/skin`
   Do not hand-edit generated JSON. Owner is the asset/data regeneration owner, not this QA and not BUILD-SKIN-01.
2. **Verify the regenerated output**, at minimum: `index.json.actions_requested` includes `construct`; `peasant.json.actions.construct` equals `{"first":186,"last":198,"kind":"morph","donor":"data/animations/aaf/peaukr.aaf:17","frames":[186,188,191,193,196,198]}`; `frames` union includes all six; existing seven actions retain their current frames. Check that regeneration does not silently replace content from other asset workers.
3. **Presentation-layer branch is separate and untouched.** S5 ranks `_unit_action()` build→`construct` as a distinct ticket; S4 `:124-127` confirms no `anim3d.gd` change and that the 3D branch remains outstanding. Current runtime state was **not** re-read here — treat as carried/UNVERIFIED until that owner lands.
4. **Capture before any visual PASS.** S5 §6 discriminator: Layer A `pose_for(...,"construct", f/30)` must yield `[186,188,191,193,196,198]` with `pose_source == "donor_flat_root_morph"`, `visual == "UNVERIFIED"`, and never 149/237; Layer B build-order sync capture must show `|aconstruct|` batches and zero builder idle frames. No capture was run by this QA.
5. **Retain labels.** Hammer `.oss` / `buildsmoke` PFX, stage OBJs, loop/blend semantics and rendered A/B remain **UNVERIFIED** (S4 `:129-145`, S5 §7).

---

## 4. Open questions

1. Ticket id/owner for asset regeneration (`BUILD-SKIN-02` proposed by S4 `:119`; COORD assignment pending). Not settled here.
2. Donor `construct` appears in more than one AAF (S4 S2 cites 8 files / one range 186..198). Whether all such sids should be regenerated and verified, or only `peasant`, is an owner decision. **UNVERIFIED** from this pass.
3. Whether to also export `workfood/workwood/workstone` (S5 `:212` lists them as optional). Deliberately excluded from the minimal change; no action needed for QA unless scope changes.
4. Whether the 3D build/repair action branch is already assigned to another owner (S4 `:153`); untouched here.
5. Engine loop/one-shot and blend behaviour for `construct` (AAF has no loop flag) remains **UNVERIFIED** (S5 §7 Q1).
6. Visual equivalence of the exported frames to the donor build pose — no donor footage or A/B capture; **UNVERIFIED**, explicitly not a PASS.

---

## 5. Summary

- **Landed change (observed):** `BUILD_SKIN_01.md` is present and `convert_skins.py` differs from its backup in one hunk only — an additive citation comment plus `construct` appended once to `DEFAULT_ACTIONS` (`convert_skins.py:69-81`). All functions and every other top-level assignment are AST-identical to the backup (derived).
- **Code-level checks PASS:** Python 3.14 in-memory compile succeeds; action tuple is exactly the original seven plus `construct`; `frames_per_action = 6` and schema unchanged; backup SHA-256 matches the owner's reported value; `sample_frames(186,198,6)` derives `[186,188,191,193,196,198]`, matching donor `peaukr.aaf:17` (`"construct",186,198,morph`, 13 frames @30 fps = 0.433 s). No frame range is hard-coded.
- **Export-level checks FAIL / PENDING:** `variant3d/assets/models/skin/index.json` still requests only the original seven actions, and `peasant.json` still has five actions with no `construct` and no frames 186..198. Generated assets were **not** regenerated in this check; regeneration plus a capture is still required.
- **No visual PASS, no parity claim.** The port's `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = "UNVERIFIED"` labels stand. Rendered outcome, hammer/PFX, stage art and engine playback remain UNVERIFIED.
- **Only this report was written.** No code, config, asset, test, scene or git change; no runner job; no donor binary executed or copied.

*End of QA-SKIN-CONSTRUCT-01 report.*
