---
id: BUILD-SKIN-01
title: "BUILD-SKIN-01 — export the donor peasant `construct` animation frames from compact skins (converter step only)"
date: 2026-11-25
owner: BUILD-SKIN-01 (tooling builder subagent)
status: DELIVERED__CONVERTER_ONLY__NO_ASSET_REGEN__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly two files touched: variant3d/tools/convert_skins.py (minimal additive DEFAULT_ACTIONS change) and this report. Backup created at inbox/backup/convert_skins.py.bak-BUILDSKIN01. NO generated skin asset (index.json / per-sid JSON), anim3d.gd, world3d_entities.gd, test, or app/** file was edited. No Godot runner, no direct godot, no Blender; donor read-only bytes/latin-1 only, no donor binary executed or copied."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; fresh Python 3.14 bytes split on CRLF)"
output: "docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md"
labels: [observed, derived, UNVERIFIED]
governing_rule: "Cite donor path:line or path:offset; separate observed / derived / UNVERIFIED; never claim donor parity from data-level evidence (DANIM-01 frontmatter :12; BUILD_ANIM_DIAG_01 frontmatter :12)."
verdict: "Converter now includes `construct` in DEFAULT_ACTIONS. Donor re-read confirms data/animations/aaf/peaukr.aaf:17 = \"construct\",186,198,morph. No frame range is hard-coded: read_aaf derives first/last/donor citation from each unit's own AAF (:118-137, :210-218). Generated skin assets are NOT regenerated here; that remains a separate offline asset/data-owner ticket."
---

# BUILD-SKIN-01 — export donor peasant `construct` frames (converter step)

## 1. Evidence read (all read-only)

| # | Source | Used for |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md` | root cause; rank-2 skin-export gap `:153-169,195,212`; expected frames `[186,188,191,193,196,198]` `:212,239,244` |
| S2 | `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md` | 62-name catalog; `construct` 8 files / one range `186..198` / 13 frames / 0.433 s `:159,224`; peasant clip table `peaukr.aaf:17` `:405`; state→name chain `:325`; "do not hard-code ranges for the 55 shipped sids" `:550-552` |
| S3 | `docs/coord_swarm_2026-11-25/reports/DANIM_02.md` | independent re-verification: 43/43 clip-table rows correct; peasant chain `peaukr.prop:54 → acl.lib:238-239 → peasant.acl` `:247`; no parity claim `:338-339` |
| S4 | `variant3d/tools/convert_skins.py:69-73` (read before edit) | `DEFAULT_ACTIONS` omitted `construct`; `read_aaf` `:118-137`; `sample_frames` `:140-149`; per-action export `:205-219`; index emission `:302-318` |
| S5 | fresh read-only donor bytes probe (temp, deleted) | verbatim `data\animations\aaf\peaukr.aaf` rows and line numbers |

## 2. Donor truth — fresh re-read (observed)

Probe read `C:\Games\Cossacks 3\data\animations\aaf\peaukr.aaf` read-only as bytes, split on
`\r\n`, never executed or copied. Relevant verbatim row:

| Donor citation | Verbatim row | Derivation |
|---|---|---|
| `data/animations/aaf/peaukr.aaf:17` | `"construct",186,198,morph` | inclusive **186..198** = 13 frames; at the `.oss` header fps 30 (`data/actors/units/peaukr.oss:0x4`, BUILD_ANIM_DIAG_01 `:75`, DANIM_02 `:90`) = **0.433 s** |

Full active-row census of the fresh read: lines 3–20, 18 rows — `idle 64..113` (`:3`),
`idle0 64..113` (`:4`), `walk 1..20` (`:5`), `death 115..149` (`:6`),
`attack0 237..254` (`:7`), `workfood/workwood/workstone` (`:8-10`), carry/idle variants
(`:11-16`), **`construct 186..198` (`:17`)**, `reaction` (`:18`),
`prepare0/unprepare0 64..65` (`:19-20`). This matches DANIM_01 §5 `:398-405` and
DANIM_02 §4.1 `:247` exactly.

Supporting donor chain (from S1/S2/S3, not re-probed here):
`gc_statetag_action_build = 1 shl 8` (`data/scripts/dmscript.global:13`) →
`gc_anim_construct = 'construct'` (`dmscript.global:926`) selected at
`data/scripts/lib/unit.script:10877`; AAF + `.oss` bound by `peaukr.actor:4-6`;
`peaukr.prop:54` → `acl.lib:238-239` → `peasant.acl:2245-2252`
(`From`/`Name`/`AnimationName = construct`, `OnAclAnimationReachedConstruct`).
The same action selects the separate hammer `.oss` (`unit.script:7008`).

## 3. Before → after (the only code change)

Before (`convert_skins.py:69-73`):

```python
# Actions worth shipping. "idle"/"walk"/"death" are the only ones the shipped
# renderer asks for (world3d_entities.gd:506-511); the rest are real donor AAF
# entries exported for completeness. All are taken from each unit's OWN AAF.
DEFAULT_ACTIONS = ("idle", "idle0", "walk", "walk0", "death",
                   "attack0", "attack1")
```

After (`convert_skins.py:69-81`): an **additive** citation comment plus one tuple
element appended. The original seven actions keep their order and values; the only
new member is the last one, `construct`.

```python
DEFAULT_ACTIONS = ("idle", "idle0", "walk", "walk0", "death",
                   "attack0", "attack1", "construct")
```

The appended comment records the exact donor citations
(`peaukr.aaf:17` = `"construct",186,198,morph`; `dmscript.global:13, :926`;
`unit.script:10877`; `peasant.acl:2245-2252`) and states explicitly that **no range is
hard-coded**: `read_aaf` (`:118-137`) already derives `first`, `last` and the `donor`
citation from each unit's own AAF at export time (`:210-218`), so the regenerated
peasant entry will carry `donor = "data/animations/aaf/peaukr.aaf:17"` and
`first=186, last=198` (**derived**, not yet exported). Sids whose AAF lacks
`construct` are skipped by the existing `if name not in acts: continue` (`:208-209`);
no other action's exported frames change.

No change was made to `sample_frames`, `read_aaf`, `convert_unit`, the decimation
count, or the index schema. Per DANIM_01 §8 `:550-552`, hard-coding a `186..198`
range into the tool would be wrong for the other 54 shipped sids; the per-sid AAF
remains the source of truth.

## 4. Backup

| Item | Value |
|---|---|
| Path | `inbox/backup/convert_skins.py.bak-BUILDSKIN01` |
| Created | before the edit, via `Copy-Item` |
| Verification | SHA-256 of backup and pre-edit original both `BC0986FBE32553EA315DE87D3BF414F9DB9A809F7CFBCE278C5C4F8BFC0848EE` |

## 5. Validation (static only — no runner, no Godot)

| Check | Command / method | Result |
|---|---|---|
| Syntax | `python -m py_compile variant3d/tools/convert_skins.py` (Python 3.14) | **PASS**, exit 0 |
| Bytecode hygiene | `PYTHONPYCACHEPREFIX` redirected to the approved temp folder; temp files deleted afterwards | repo `variant3d/tools/__pycache__` unchanged (e.g. `convert_skins.cpython-314.pyc` still dated 11/24/2026); no new `__pycache__` in the repo |
| Action table | read-only `importlib` load of the edited file; assert original 7-tuple unchanged and `construct` appended exactly once | **PASS**: `DEFAULT_ACTIONS = ('idle','idle0','walk','walk0','death','attack0','attack1','construct')` |
| Expected frames | `sample_frames(186, 198, 6)` | **PASS**: `[186, 188, 191, 193, 196, 198]` — matches BUILD_ANIM_DIAG_01 `:212,239` |
| No asset writes | no converter invocation with `--out`; git status/diff reviewed | only `convert_skins.py` among owned files differs; no skin JSON written |

`python -m py_compile` ran with a redirected cache prefix specifically so no repo
`__pycache__` was created or modified. **Not run:** the converter itself, any Godot
runner, `godot`, Blender, or any A/B capture.

## 6. Remaining ticket — asset regeneration (NOT done here)

This ticket changes only the converter's action set. The shipped compact skins are
still the old export, so at runtime `construct` frames remain absent until the
converter is re-run offline. Hand-off:

| Field | Value |
|---|---|
| Proposed id | `BUILD-SKIN-02` (to be confirmed/assigned by COORD) |
| Owner | **asset/data regeneration owner** — explicitly *not* BUILD-SKIN-01 and not this worker; the converter edit is already landed |
| Scope | regenerate `variant3d/assets/models/skin/index.json` and per-sid skin JSON (at minimum `peasant.json`); verify `actions.construct.frames == [186,188,191,193,196,198]` and `donor == "data/animations/aaf/peaukr.aaf:17"`; do not hand-edit generated JSON |
| Exact command (from `convert_skins.py:46-50`) | `python variant3d/tools/convert_skins.py --game "C:\Games\Cossacks 3" --manifest variant3d/assets/models/manifest.json --out variant3d/assets/models/skin` |
| Mode | offline, read-only donor; no Godot/runner needed for the export itself |

BUILD-ANIM-01 is standing down from `anim3d.gd` (`BUILD_ANIM_01.md:1-27`); no
`anim3d.gd` change is required (`BUILD_ANIM_DIAG_01:213`, `build_anim_diag` verdict).
The separate `world3d_entities.gd:_unit_action()` build→construct branch remains a
distinct presentation-layer ticket and is untouched here.

## 7. UNVERIFIED labels (carried forward, not settled by this edit)

- **hammerPFX / tool:** the donor switches a separate single-bone hammer `.oss`
  (`data/scripts/lib/unit.script:7008`) and construction smoke is a separate site
  PFX family (`buildsmoke*.actor`, `pfxbuildsmoke*.aaf`, `actors.lib:2490-2511`).
  Neither is exported by this converter change; spawn policy and 3D presentation
  remain **UNVERIFIED** (BUILD_ANIM_DIAG_01 `:81-83,197,215-218`).
- **visual A/B / parity:** donor skin equation form, quaternion convention and any
  rendered comparison remain **UNVERIFIED** (DANIM_01 §6.3 `:521-524`; DANIM_02
  frontmatter `:18`, §4.3 `:288`). This is a data-level export change only.
  Labels `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = "UNVERIFIED"` stay
  exactly as generated by `convert_skins.py:61,238`.
- **Loop/one-shot and blend:** AAF has no loop flag; `construct` loop policy is
  authored in ACL/scripts (`showdebuganimations.inc:143`, `peasant.acl:2245-2252`)
  and engine semantics are **UNVERIFIED**. No runtime behaviour is claimed.
- **Rendered outcome:** that the exported frames will render as a distinct build
  pose is **derived/inferred**, not observed; no capture was run.

## 8. Open questions

1. Ticket id/owner for the asset regeneration (`BUILD-SKIN-02` proposed here) needs COORD assignment.
2. Whether to also export `workfood/workwood/workstone` (BUILD_ANIM_DIAG_01 `:212` lists them as optional); deliberately **not** included in this minimal ticket.
3. Regeneration changes 55 skin JSONs plus `index.json`; review/conflict policy with other asset workers is an owner decision.
4. Hammer `.oss` and `buildsmoke` PFX presentation remain out of scope (V764 Q3 / BUILD_ANIM_DIAG_01 Q2/Q5).
5. Whether the 3D build-order action branch in `world3d_entities.gd` is already assigned elsewhere; untouched here.
6. No donor-parity or visual-equivalence evidence was produced; no claim made.

## 9. Summary

- **Donor citations (fresh read, observed):** `data/animations/aaf/peaukr.aaf:17` =
  `"construct",186,198,morph` → 186..198 inclusive, 13 frames @30 fps = 0.433 s;
  selected by `dmscript.global:13,926` / `unit.script:10877` and bound in
  `peasant.acl:2245-2252` (chains from S1/S2/S3).
- **Before → after:** `convert_skins.py` `DEFAULT_ACTIONS` gained exactly one
  additive member, `"construct"`, plus a citation comment; the seven original
  actions and all donor readers/sampling logic are unchanged. No hard-coded range.
- **Backup:** `inbox/backup/convert_skins.py.bak-BUILDSKIN01`, SHA-256 matched pre-edit original.
- **Validation:** `python -m py_compile` PASS; read-only assertions PASS
  (original 7 unchanged, `construct` present once, `sample_frames(186,198,6) ==
  [186,188,191,193,196,198]`); no repo `__pycache__` changed; no runner/Godot/donor execution.
- **Remaining:** offline asset regeneration by the asset/data owner with the exact
  command in §6; generated skins are still the old export until then.
- **Labels:** hammer/tool PFX and visual A/B **UNVERIFIED**; `PORT APPROXIMATION —
  NOT DONOR PARITY` retained. No donor-parity claim.
- **Files edited:** `variant3d/tools/convert_skins.py` and this report only. No
  generated skin asset, `anim3d.gd`, `world3d_entities.gd`, test, or `app/**` file
  was edited by this worker. No donor file was executed or copied.

*End of BUILD-SKIN-01 report.*
