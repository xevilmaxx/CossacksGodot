---
id: B-T2B-NATION-ENT
owner: B-T2B-NATION-ENT (implementation builder)
task: "T2b + stale-constants refresh — variant3d/scripts/world3d_entities.gd only"
date: 2026-11-25
status: DELIVERED — CODE CHANGED (3 hunks, +28/−5) + ONE PARSE SMOKE
mode: "single-file ownership (world3d_entities.gd + this report only); backup first and byte-verified; donor cites carried from named read-only reports (donor text NOT re-read this pass); one variant-runner parse smoke; no selftest/uitest/gate; no direct godot; no git op; app/ NEVER touched"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = bytes/artifacts read this pass | derived = deterministic comparison or code-trace over observed bytes | inferred = interpretation | UNVERIFIED = not re-read or not measurable here"
parity_claim: none
---

# B-T2B-NATION-ENT — role-substitution exactness + stale construct constants

## 1. Verdict up front

- `variant3d/scripts/world3d_entities.gd` now labels Bavaria's two generic role
  substitutions honestly: `bav/serdiuk → musketeer` and `bav/cossack → hussar`
  resolve to the on-disk mesh but report `exact=false` with the new
  `NATION_MESH_ROLE_SUB_STATUS` label. Russian nation-coded remaps
  (`strelet`, `cossackdon`) still report `exact=true`. [derived from edited code]
- Stale `CONSTRUCT_SKIN_STATUS` (`:194-198`) refreshed: it claimed shipped skins
  lack `construct` frames — false since the skin-export owner landed. Verified
  this pass that `skin/peasant.json:1` exports
  `actions.construct` frames `[186,188,191,193,196,198]`. [observed]
- Exact diff: **+28 / −5 across 3 hunks, one file**. Parse smoke passed
  (ticket **579**, `status ok`, `exit 0`, `SCRIPT ERROR` 0). [observed]
- No parity claim. Nation-art availability, the "Ukrainian look", and all
  rendered behaviour remain BLOCKED / UNVERIFIED and belong to asset owners.
  [observed]

## 2. Backup evidence (first action, before any edit)

| Item | Value | Label |
|---|---|---|
| Path | `inbox/backup/world3d_entities.gd.bak-BT2B` | observed |
| Pre-existence | none — the path was absent before this pass; created once, never overwritten | observed |
| Size | 104,622 B (live and backup at backup time) | observed |
| SHA-256, live at backup time | `753B9B118F8D530A3601BDE25F4E46C19D367AF0709F8F35318663F483ADA530` | observed |
| SHA-256, backup | `753B9B118F8D530A3601BDE25F4E46C19D367AF0709F8F35318663F483ADA530` | observed |
| Full byte-sequence compare | `byte_identical=True` (every byte, not just the hash) | observed / derived |

## 3. Exact diff (3 hunks, `git diff -- variant3d/scripts/world3d_entities.gd`)

### Hunk 1 — stale-constants refresh (was `:194-198`, now `:194-201`)

Old comment + `CONSTRUCT_SKIN_STATUS` claimed the shipped compact skins
(`skin/index.json`, `skin/peasant.json`) "do not export construct frames" and
that `pose_for()` may snap donor 186..198 to death 149 / attack0 237
(`BUILD-ANIM-DIAG-01 §5 step 2`). That premise is stale: `B_ANIM_DIAG2 §2.4`
records the build branch (`world3d_entities.gd:1183-1191`) and the construct
skin export (`convert_skins.py:80-81`, `peasant.json:1`) as both landed.
Re-verified this pass: `peasant.json:1` `actions` keys are
`idle, idle0, walk, death, attack0, construct`, with
`construct = first 186, last 198, frames [186,188,191,193,196,198]`.
[observed file bytes; converter lines carried from `B_ANIM_DIAG2:129`, not re-read]

New constant text (same identifier — **no rename of any called symbol**):

```gdscript
const CONSTRUCT_SKIN_STATUS: String = PORT_LABEL + " — 'construct' selected for build/repair; shipped peasant skin exports construct frames [186,188,191,193,196,198] (skin/peasant.json:1 actions.construct, convert_skins.py:80-81); pose_for resolves construct without death/attack0 snap; gather/resow/carry/attack still resolve to idle/walk (no branch); visual UNVERIFIED"
```

Still `PORT APPROXIMATION`-prefixed, still `visual UNVERIFIED`; the surviving
gather/resow/carry/attack gap is stated, not fixed (separate owner per
`B_ANIM_DIAG2 §4`). [derived]

### Hunk 2 — new role-substitution constants (after `:203`)

```gdscript
const NATION_MESH_ROLE_SUB_STATUS: String = PORT_LABEL + " — generic donor role substitute on disk, NOT nation-unique art (bav serdiuk->musketeer / cossack->hussar via data.gd:296; donor generic U:771-785/U:1347-1353; bav uniques absent); visual UNVERIFIED"
const NATION_ROLE_SUB_SIDS: Array[String] = ["musketeer", "hussar"]
```

Design call per `B_NATION_PLAN2:117-118` (left to owner): a dedicated status
string plus an explicit generic-role set, alongside — not replacing —
`NATION_MESH_FALLBACK_STATUS`. Donor cites carried from `B_NATION_PLAN2:67`
(`musketeer` `U:771-785`/`C:2700`, `hussar` `U:1347-1353`/`C:2754`,
uniques `musketeer18bav`/`grenadierbav` absent `NATION_DATA_01:94-95`); donor
text not re-read this pass. [inferred design; carried cites]

### Hunk 3 — `_entity_mesh_sid()` role-substitution gate (was `:737-777`)

- `var role_sub := false` hoisted before the family match; set `true` only in
  the `units` branch when `Data.resolve_sid(nation, base_sid)` returns a sid in
  `NATION_ROLE_SUB_SIDS` (i.e. exactly the `data.gd:296` bav mappings).
- After the existing disk-probe loop (untouched), `if role_sub and exact:`
  resets `exact = false` and switches `status` to
  `NATION_MESH_ROLE_SUB_STATUS`. `sid`, `candidate`, and `candidates` are
  **unchanged** (traceability preserved per plan §T2b).
- Untouched by this hunk: `sid := base_sid` fallback (`:765`), fallback status
  selection (`:774`), `_donor_building_prefix()` (`:692-717`), the naval
  `pass` branch (`:763-764`), rotor/stage/tree/motion blocks, and every
  `NATION_UNITS` input row (T2a 0-diff state consumed as-is; `data.gd` clean
  in `git status`). [observed `git diff` + `git status`]

## 4. Post-fix resolution matrix (derived code-trace, NOT a run claim)

Traced by hand over the edited `_entity_mesh_sid()` with T2a's locked rows
(`data.gd:295-296`) and T2a's OBJ-existence result (all 14 targets have
`obj/<target>.obj`). Runtime `ResourceLoader.exists` outcomes are UNVERIFIED
here; the matrix states what the code selects **given** a disk hit:

| Nation | Army sid | `resolve_sid` | Disk hit | `chosen` / `candidate` | `exact` after fix | Label |
|---|---|---|---|---|---|---|
| rus | `serdiuk` | `strelet` | yes | `strelet` | **true** | nation-coded, donor-grounded (`U:931-937`) |
| rus | `cossack` | `cossackdon` | yes | `cossackdon` | **true** | nation-coded (`U:1480-1488`) |
| bav | `serdiuk` | `musketeer` | yes | `musketeer` | **false** | role substitute (was mislabelled `true`) |
| bav | `cossack` | `hussar` | yes | `hussar` | **false** | role substitute (was mislabelled `true`) |
| rus/bav | `pikeman`/`archer`/`officer`/`cannon` | identity | n/a | base sid | false (fallback, unchanged) | pre-existing conservative label, preserved |
| rus/bav | buildings `cen`/`bar`/`mil` | prefix probe | miss | base sid, `candidate=ruscen/bavbar/eurmil` | false (fallback, unchanged) | BLOCKED — no asset fix in this ticket |
| rus/bav | naval `yacht` | none | n/a | `yacht`, `candidates=[]` | false, unchanged | parked per plan §T2c |

No blocked-sid row was added anywhere (`pikemanrus`, `officerrus`, `pearus`,
`musketeer18bav`, `grenadierbav`, `peaaus`, `bavmil`, `bavpor`, `hetman`-for-rus,
naval remaps: none present, none invented). [derived]

## 5. Validation job evidence (one submission, variant spool only)

Per governance (one targeted validation via variant runner only; `RUN_GUIDE.md:35-55`):

- Queue preflight: `now_serving = 579`, `next_ticket = 579`, `pending 0`,
  `godot.lock = free` — quiet before submission. [observed]
- Command (submitted **once**, never re-submitted):
  `python variant3d\tools\godot_runner.py run --id bt2b-nation-ent-parse --timeout 300 -- --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd`
- Runner output: `[runner] ticket 579 'bt2b-nation-ent-parse' START (waited 0.00s)` /
  `[runner] ticket 579 'bt2b-nation-ent-parse' END ok (run 5.40s)`. [observed]
- `status.json` history entry **ticket 579**: `id=bt2b-nation-ent-parse`,
  `status="ok"`, `exit=0`, `wait≈0.00s`, `run=5.40s`, `timeout=300`. [observed]
- Artifacts: `variant3d/.godot_queue/results/00000579_bt2b-nation-ent-parse/stdout.txt`
  (73 B: Godot 4.7.2 stable banner only); `stderr.txt` empty (0 B).
  **`SCRIPT ERROR` lines = 0.** [observed]
- Probe result: parse-only smoke passes; sid→mesh resolution values in §4 are a
  static code-trace, not a runtime probe — a runtime 14-case probe would need a
  new test file under `variant3d/`, which is outside this ticket's ownership,
  so none was authored or run. No selftest/uitest/gate, no direct `godot`, no
  2D-runner invocation. [observed / governance restraint]
- Symbol safety: repo-wide grep for `CONSTRUCT_SKIN_STATUS`,
  `construct_action_status`, `NATION_ROLE_SUB_SIDS`,
  `NATION_MESH_ROLE_SUB_STATUS` hits only `world3d_entities.gd` itself (decl +
  two use sites) — no test or foreign module asserts on the changed strings.
  [observed]

## 6. Scope — what was NOT touched

`app/` untouched. `data.gd` (T2a owner, still 0-diff — `git status` clean for it),
`game.gd`, `world3d_fx.gd`, `anim3d.gd` untouched by this builder (their
`M` flags in `git status` belong to other owners: BBCLAMP/BGHOST-family backups
present in `inbox/backup/`). No rotor/stage/tree/motion block byte changed
(diff shows only the 3 hunks above). No OBJ/manifest/texture write, no new
nation OBJs, no blocked-sid rows, no `hetman` for Russia, no MORALE bytes, no
naval remap, no `PORT APPROXIMATION` label removal, no called-symbol rename,
no test edit. The only files created by this pass are the named backup and this
report. [observed — `git status --short`, `git diff --stat`: 1 file, +28/−5]

## 7. Open questions / UNVERIFIED

1. Runtime `ResourceLoader.exists` hits for `musketeer`/`hussar`/`strelet`/
   `cossackdon` and the `nation_mesh_usage` histogram were not measured here
   (no runtime probe run); §4 `exact` values assume the T2a-verified OBJ set.
   [UNVERIFIED]
2. Donor `unit.script` / `country.script` line cites are **carried** from
   `B_NATION_PLAN2` / `B_ANIM_DIAG2` / `NATION_DATA_01`; donor text was not
   re-read by this builder. [UNVERIFIED independently this pass]
3. Whether the role-substitute label should also apply on disk-miss (currently
   falls back to `NATION_MESH_FALLBACK_STATUS`) is a follow-up owner call; the
   fallback path was deliberately preserved. [inferred]
4. No donor render or port screenshot was examined; every visual outcome stays
   UNVERIFIED. No full gate was run (COORD-last restraint). [UNVERIFIED]

*End of B-T2B-NATION-ENT — code change confined to world3d_entities.gd (3 hunks, +28/−5); one parse smoke (ticket 579, ok/exit 0/SCRIPT ERROR 0); no donor binary executed or copied; no visual or donor-parity claim.*
