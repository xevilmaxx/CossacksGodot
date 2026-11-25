---
id: B-T2A-NATION-DATA
owner: B-T2A-NATION-DATA (implementation builder)
task: "T2a — exact NATION_UNITS / UNITS_BASE rows, variant3d/scripts/data.gd only"
date: 2026-11-25
status: DELIVERED — NO BYTE CHANGE REQUIRED (file already at plan's final state)
mode: "single-file ownership (data.gd + this report only); backup first and byte-verified; donor cites carried from named read-only reports (donor text NOT re-read this pass); one variant-runner parse smoke; no selftest/uitest/gate; no direct godot; no git operation beyond status; app/ never touched"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = bytes/artifacts read this pass | derived = deterministic comparison over observed bytes | inferred = interpretation | UNVERIFIED = not re-read or not measurable here"
parity_claim: none
---

# B-T2A-NATION-DATA — T2a nation-data lock (no-op diff)

## 1. Verdict up front

- `variant3d/scripts/data.gd` is **already at exactly the final state B_NATION_PLAN2 §T2a specifies**: the `rus` and `bav` rows match the plan's KEEP-byte-identical strings verbatim, `ukr`/`pol`/`tur`/`alg`/`swe`/`sco` are present, and no ADD row is authorized without sign-off. [observed]
- **Exact diff applied: +0 / −0 / 0 bytes changed.** No line was added, removed, renamed or retuned. `git status --short -- variant3d/scripts/data.gd` is empty; the live file and the pre-edit backup compare byte-identical. [observed]
- The only candidate ADD, `rus.reiter → vityaz`, is **sign-off gated and deferred** (§5) — not applied. [observed plan text + derived decision]
- Parse smoke passed (ticket **576**, `status ok`, `exit 0`, `SCRIPT ERROR` 0). MORALE content hashes are unchanged. No parity claim; nation-art availability and mesh exactness remain BLOCKED / UNVERIFIED and belong to T2b + asset owners. [observed; `B_NATION_PLAN2:16-18,54-58`]

## 2. Backup evidence (first action, before any edit)

| Item | Value | Label |
|---|---|---|
| Path | `inbox/backup/data.gd.bak-BT2A` | observed |
| Pre-existence | none — the path was absent before this pass; created once, never overwritten | observed |
| Size | 88,123 B (live and backup) | observed |
| SHA-256, live | `89B1519D5CCA412B4572B657AD40572A2B8D94C95855050F369310E2F9F1E919` | observed |
| SHA-256, backup | `89B1519D5CCA412B4572B657AD40572A2B8D94C95855050F369310E2F9F1E919` | observed |
| Full byte-sequence compare | `byte_identical=True` (every byte, not just the hash) | observed |
| Cross-check | matches the live-file hash cited by `QA_NATION_IMPL_01:21` (88,123 B, `89B1519D…E919`) | observed / derived |

The live hash is also the hash of the **committed** file (`git status` clean for `data.gd`), so "no diff" here means no change against the shipped tree, not merely no change against a mid-pass snapshot. [derived]

## 3. Exact diff — keep / add / do-not-add (per `B_NATION_PLAN2 §3`)

### 3.1 KEEP byte-identical — verified verbatim from `data.gd:294-306`

| Nation | Exact row text (as on disk) | Donor cite (carried) | Result | Label |
|---|---|---|---|---|
| `rus` (`:295`) | `{"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"}` | `strelet`: country.script:2693 / unit.script:931-937; `cossackdon`: country.script:2767 / unit.script:1480-1488; `pope`: country.script:2741 (`NATION_DATA_01:24,60,156`) | byte-for-byte match to plan (`expected_row_match.rus = true`) | observed (bytes) / donor cites carried, not re-read |
| `bav` (`:296`) | `{"serdiuk": "musketeer", "cossack": "hussar"}` | `musketeer`: country.script:2700 / unit.script:771-785; `hussar`: country.script:2754 / unit.script:1347-1353 (`NATION_DONOR_01:105`; `B_NATION_PLAN2:67`) | byte-for-byte match to plan (`expected_row_match.bav = true`) | observed (bytes) / donor cites carried, not re-read |
| `ukr` (`:297`) | `{"priest": "pope"}` | `NATION_DATA_01:143-152` | present, unchanged | observed |
| `pol` (`:298`) | `{"cossack": "wingedhussar"}` | `DUNIT_01:251`; `NATION_DATA_01:143-152` | present, unchanged | observed / donor cite carried |
| `tur` (`:299`) | `{"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "sipahi", "dragoon": "sipahi", "priest": "mullah"}` | `DUNIT_01:247`; `NATION_DATA_01:143-152` | present, unchanged | observed / donor cite carried |
| `alg` (`:300`) | `{"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "mameluke", "dragoon": "spakh", "priest": "mullah"}` | `DUNIT_01:248`; `NATION_DATA_01:143-152` | present, unchanged | observed / donor cite carried |
| `swe` (`:301`) | `{"cossack": "hackapell"}` | `DUNIT_01:252`; `NATION_DATA_01:143-152` | present, unchanged | observed / donor cite carried |
| `sco` (`:305`) | `{"drummer": "bagpiper", "musketeer": "sco_highlandersword", "serdiuk": "sco_highlandersword"}` | `data.gd:302-305` P-41 comment; `NATION_DATA_01:143-152` | present, unchanged | observed |

Note on `rus.dragoon → cossackdon`: this is donor-grounded only as an approximation (Russia has no 17c `dragoon`, country.script:2778; `dragoon18` at :2784 has no exact port sid) — carried from `NATION_DATA_01:156`; it is deliberately untouched, not newly introduced. [inferred, carried]

The `bav` line is the one inserted by the earlier NATIONDATA01 owner; `QA_NATION_IMPL_01:39` records `+1/−0`, one hunk, live `:296`. This pass does **not** re-add it. [observed / derived]

### 3.2 ADD rows — none applied

The only ADD candidate in §T2a is `rus.reiter → vityaz`, marked **OPTIONAL, SIGN-OFF GATED** and **deferred** in `B_NATION_PLAN2:69`. No sign-off was received, and adding it would change Russian AI army picks and shift deterministic selftest traces (`NATION_DATA_01:147,212`; `NATION_DATA_IMPL_01:130`). Decision and evidence in §5. **No other ADD row exists in the plan.** [observed]

### 3.3 DO NOT ADD — none present (negative check)

Blocked target set checked against every `NATION_UNITS` target in the live file:

`pikemanrus`, `officerrus`, `pearus`, `drummerrus`, `musketeer18bav`, `grenadierbav`, `peaaus`, `dragoon18`, `ferry`, `chaika`, `yachtrus`, `rus_yacht`, `bavmil`, `bavpor`, `hetman`.

Result: `blocked_targets_present = []`. Additionally `rus_has_hetman = false` and no `bavmil`/`bavpor` sid appears anywhere in the mapping block. [observed]

The blocked-set rationale is carried from `B_NATION_PLAN2:70,96`, `NATION_DATA_01:148-150`, `NATION_DONOR_01:188-190,208,210`: those sids have no `UNITS_BASE` row and no OBJ (or are Ukraine-only, in the case of `hetman`), so `resolve_sid()` would reject them at `data.gd:1568`, and inventing `bavmil`/`bavpor` OBJs is explicitly rejected. [carried / observed absence on disk]

## 4. Acceptance probe results (read-only; no full gate)

Static content check per `B_NATION_PLAN2:72`, run from a temp script (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\bt2a_probe.py`, outside the repo):

| Check | Result | Label |
|---|---|---|
| `NATION_UNITS` block line span | `:294-306` (content-anchored, not line-number assumed) | observed |
| Nation rows parsed | 8: `rus, bav, ukr, pol, tur, alg, swe, sco` — exactly the plan's KEEP set | observed |
| Every target is a top-level `UNITS_BASE` key | yes — 14 distinct targets, all present among 62 top-level keys | observed / derived |
| Every target has `variant3d/assets/models/obj/<target>.obj` | yes — 14/14 (`strelet, cossackdon, pope, musketeer, hussar, wingedhussar, jannisary, sipahi, mullah, mameluke, spakh, hackapell, bagpiper, sco_highlandersword`) | observed |
| `all_targets_backed` | `true` | derived |
| Blocked targets / `rus` reiter / `rus` hetman | none | observed |
| `UNITS_BASE` row bytes (`vityaz` `:956`, etc.) | unmodified — full-file byte comparison passes | observed |

### MORALE content-hash probe (per `B_NATION_PLAN2:72`, `NATION_DATA_01:158-164,216`)

Regions selected by **content anchors**, not by line number; SHA-256 computed over the exact bytes including line endings:

| Region | Anchor | Live lines | Backup lines | Bytes | SHA-256 (live == backup) | Equal |
|---|---|---|---|---|---|---|
| A | `static var MORALE_BASE` … `static var PORT_MORALE_FAMINE_ENABLED` (includes all `MORALE_*`, officer/drummer aura, PRIEST_HEAL_*, ARTILLERY_DEPLOY, dispersion banners/constants) | 99-132 | 99-132 | 2,217 | `0308E3204624FCEAD71C77C6FD9FA068041E7E1CBC8495FF1E0D87A1098950E4` | **yes** |
| B | PORT-APPROXIMATION banner immediately before `SQUAD_XP_PER_KILL` … `static var SQUAD_XP_CAP` | 588-602 | 588-602 | 1,019 | `AC70A807A310D462B4C55AF363B3EFA843FA6B1D3394392C7CAADCE94E8CF734` | **yes** |

Both regions were hashed from backup and live independently and are equal by content. Because this pass made no edit, the line numbers also coincide; the method would still have detected a shifted-but-identical region (the false-positive case warned about in `NATION_DATA_01:164`). Full-file SHA-256 equality (§2) independently covers every MORALE byte in the file. [observed / derived]

## 5. `rus.reiter → vityaz` sign-off line

**SIGN-OFF: NOT GRANTED — ROW NOT APPLIED (DEFERRED).** `B_NATION_PLAN2:69` labels this ADD "OPTIONAL, SIGN-OFF GATED" and "deferred"; `B_NATION_PLAN2:118` and `NATION_DATA_01:147,212` require an owner decision plus a seed-trace re-baseline because AI orders generics (`country.script:2773` excludes rus from generic reiter; `vityaz` carries the reitar role at `country.script:2768`, `unit.script:1489-1496`) and a remap would change Russian AI army picks and deterministic selftest traces. `NATION_DATA_IMPL_01:130` already records the same deferral. Both `reiter.obj` and `vityaz.obj` exist and both have `UNITS_BASE` rows (`:880`, `:956`), so the blocker is governance/trace stability, not assets. [observed plan text + carried donor cites; inferred decision]

Acceptance criterion in `B_NATION_PLAN2:72` — "rus and bav rows match byte-for-byte **except an explicitly signed-off reiter add**" — is met in its no-add branch (`expected_row_match.rus = true`, `rus_has_reiter = false`). If an owner later signs off, the row belongs to a separate ticket with a re-baselined seed trace; it is not a silent addition here. [derived]

## 6. Validation job evidence (one submission, variant spool only)

Per `RUN_GUIDE.md:35-55` and the plan's "--check-only parse smoke only" constraint:

- Queue preflight: `now_serving = 575`, `counter = 575`, `jobs/` empty, no `godot.lock` — quiet before submission. [observed]
- Command (submitted **once**, never re-submitted):
  `python variant3d\tools\godot_runner.py run --id bt2a-nation-data-parse --timeout 300 -- --headless --path variant3d --check-only --script res://scripts/data.gd`
- Runner output: `[runner] ticket 576 'bt2a-nation-data-parse' START (waited 280.59s)` / `[runner] ticket 576 'bt2a-nation-data-parse' END ok (run 8.15s)`. [observed]
- `status.json` history entry **ticket 576**: `id=bt2a-nation-data-parse`, argv `["--headless","--path","variant3d","--check-only","--script","res://scripts/data.gd"]`, `wait=280.59s`, `run=8.15s`, `timeout=300`, **`status="ok"`, `exit=0`**. [observed]
- Artifacts: `variant3d/.godot_queue/results/00000576_bt2a-nation-data-parse/stdout.txt` contains only the Godot 4.7.2 stable banner; `stderr.txt` is empty. **`SCRIPT ERROR` lines = 0.** [observed]
- No selftest, uitest, full gate, `--stay`, `ack`, `reset`, `doctor`, direct `godot`, or 2D-runner invocation was made by this builder. [observed]

## 7. Scope — what was NOT touched

`app/` untouched. `game.gd`, `world3d_entities.gd`, `config.gd`, `config.json`, `pattern_gen.gd`, `world3d_terrain.gd`, `terrain_tileindex.gdshader`, `hud3d_adapter.gd` and every test file untouched (their pre-existing modifications by other owners are unrelated to this pass). No entity hookup (T2b), naval (T2c), building prefixes, OBJ/manifest/asset writes, new nation OBJs, blocked-sid rows, `hetman` for Russia, MORALE byte change, called-symbol rename, or test weakening. [observed — `git status --short -- variant3d/scripts/data.gd` empty; only two files created by this pass are the named backup and this report]

## 8. Open questions / UNVERIFIED

1. Donor `unit.script` / `country.script` lines cited in §3 were **carried** from `NATION_DONOR_01.md`, `NATION_DATA_01.md` and `DUNIT_01_unit_roster.md`; donor text was not re-read or re-decompiled by this builder. [UNVERIFIED independently this pass]
2. Runtime mesh selection, `exact=true`/`false` labelling for `bav/serdiuk→musketeer` and `bav/cossack→hussar`, and the 12-row matrix belong to T2b (`world3d_entities.gd`, separate owner). Not measured here. [UNVERIFIED / out of scope]
3. No `rus*`/`bav*`/`eur*` 3D art exists on disk per the cited reports; the "Ukrainian look" remains BLOCKED until an asset owner lands meshes. No donor render or port screenshot was examined. [UNVERIFIED; no parity claim]
4. Whether an owner later authorizes `rus.reiter → vityaz` with a re-baselined seed trace remains an open decision (§5). [UNVERIFIED]
5. No full gate was run by this builder (governance restraint); current selftest/uitest artifact state was not assessed here. [UNVERIFIED]

## 9. Summary

- Backup created and byte-verified before any edit; live `data.gd` unchanged (88,123 B, `89B1519D…E919`). [observed]
- T2a's exact KEEP rows are already on disk and verified verbatim; ADD set is empty; DO NOT ADD set is entirely absent. [observed / derived]
- Both MORALE content-hash regions are equal backup vs live (`0308E320…508E4`, `AC70A807…CF734`); full-file bytes equal. [observed]
- Parse smoke: ticket **576**, `status ok`, `exit 0`, `SCRIPT ERROR 0`; one submission. [observed]
- `rus.reiter → vityaz`: **deferred, not applied** — no sign-off, re-baseline required. [observed / inferred]
- No parity claim is made; T2b/asset gaps stay BLOCKED / UNVERIFIED. [observed]

*End of B-T2A-NATION-DATA — no code, asset, config, test, gate or git change beyond the named backup and this report; no donor binary executed or copied; no full-selftest/uitest run; no visual or donor-parity claim.*
