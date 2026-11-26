---
id: X70
ticket: "TERRAIN-SWARM-2026-11-26 / X70 — decide whether X57's envscales.cfg literals should be wired into I09 now"
title: "X70 — 26-group envscales scale/jitter census vs I09 per-family scale handling: DEFERRED, no new constants"
agent: "X70 (READ-ONLY donor-first analysis subagent, worker X70; reports to COORD)"
owner_file: docs/terrain_swarm_2026-11-26/reports/X70_envscales_i09.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_RUNNER_JOB__NO_DONOR_BINARY
labels: [O, D, I, U, "PORT APPROXIMATION"]
verdict: "DEFERRED — 0 of 26 donor groups are skirmish-relevant as a hard donor constant; NO paste-ready constant block issued; NO new constants; I09 file UNCHANGED (SHA-256 C990F604…94B matches V59)."
parity_claim: false
parity_guard: "NO DONOR PARITY CLAIM. No donor binary executed, no donor GPU A/B frame exists (CHARTER.md:43-44,122-130). All statements are static [O]/[D]/[I]/[U] or PORT APPROXIMATION."
scope_guard: "Exactly ONE repo file written (this report). Donor read in place at C:\\Games\\Cossacks 3 (READ ONLY). Scratch only in %TEMP%\\opencode\\x70_groupscan.py. No .gd/.gdshader/.json/.cfg/.import/asset/test/fixture/git/app edit; no Godot process, gate, capture or runner job."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/X57_env_objects_decode.md
  - docs/terrain_swarm_2026-11-26/reports/V59_i09_audit.md
  - docs/terrain_swarm_2026-11-26/reports/F08_flora_minerals.md
  - docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md
  - variant3d/scripts/terrain_donor_props.gd (1,022 lines; SHA-256 C990F604F17B650E4F29F03335EEA70FB6C9ADCF83C385F7CD1CBDE82625C94B)
  - donor: data\\game\\var\\envscales.cfg, scripts\\editor.inc\\createenvironemttest.inc, scripts\\editor.aix, data\\objects\\env\\field.prop, data\\pattern\\pattern.lib, data\\scripts\\common.inc\\dogenerate.inc, data\\game\\var\\generator.cfg (all READ ONLY)
passes: "P1 mandatory-read pass; P2 independent 26-group/122-entry donor census (scale/minscale/maxscale + 160 negative); P3 editor-consumer and dogenerate call-site verification; P4 I09 hash + full-token scan for scale/min/max/jitter/envscales/DONOR_UNITS; P5 cross-source contradiction + pattern.lib Scaling pass; P6 guardrail decision pass."
donor_root: "C:\\Games\\Cossacks 3 (READ ONLY, private use)"
---

# X70 — should X57's `envscales.cfg` literals be wired into I09 now?

## 0. Executive verdict

**[O]/[D] DEFERRED. Zero of the 26 donor groups should be promoted to a hard donor
constant in `variant3d/scripts/terrain_donor_props.gd` today. No paste-ready
GDScript constant block is issued; no new constant is added.**

The four decisive facts, each re-verified this pass:

1. **[O] The table has no skirmish consumer.** X57's corpus-wide scan (E15) found
   exactly one text caller of `data\game\var\envscales.cfg`: the editor menu tool
   `scripts\editor.inc\createenvironemttest.inc`, registered at
   `scripts\editor.aix:419-423` (re-verified: `Name = CreateEnvironemtTest` at
   `:420`, `UsedFileName` at `:422`). No `generator.cfg`, `dogenerate.inc`,
   `generatemap.inc` or `misc.script` reads it.
2. **[O] Even in that sole consumer, the `scale` value is read but never applied.**
   `createenvironemttest.inc:38` reads `scale`; its only application is inside a
   commented brace at `:46-47`
   (`{if (scale>0) then SetGameObjectScaleByHandle(goHnd, scale, scale, scale);}`).
   `minscale`/`maxscale` are used only to spawn *side-by-side comparison copies*
   (`:48-57`), not to scale the placed object. Every line is `[*] = ;` text —
   runtime activation **[U]** (X57 §4.1, §8 item 2).
3. **[O] I09 already consumes the authoritative per-object scale.** `_normalize_record`
   reads `Scaling` from each `pattern.lib` `Objects[]` record
   (`terrain_donor_props.gd:657-659`), stores it as `scale.x` (`:721`) and applies
   it uniformly at `:772-773` (`basis.scaled(Vector3(sc, sc, sc))`). For the mine
   class this literal is byte-identical to the table's mine value:
   `pattern.lib:713429-713432` `Scaling` → `X/Y/Z = 0.315200001001358`, matching
   `envscales.cfg:20` `scale = 0.3152` and `minegold.prop:141`. There is no
   second, table-level scale path to fill.
4. **[O]/[U] Promoting editor-diagnostic literals to runtime constants would be a
   "new donor constant" forbidden by CHARTER §4 (:83-84).** The table is a
   reference/diagnostic summary, not a byte-exact runtime mirror (two preserved
   contradictions, §5 below), and its runtime role beyond the editor tool is
   explicitly UNVERIFIED (X57 §4.1 verdict, §8 item 4).

**[O] No `DONOR_UNITS=160` is reintroduced** (§6). I09's file hash is unchanged
from V59's audited snapshot, so nothing in this lane modified it.

No parity claim is made anywhere in this report.

## 1. Multiple-pass register (CHARTER.md:85-93)

| Pass | Instrument | Result / effect |
|---|---|---|
| P1 | Full `read` of CHARTER, X57, V59, F08, spec/08 and all 1,022 lines of `terrain_donor_props.gd` | Established X57's extraction (26 groups / 122 entries), V59's audit verdicts, F08's Object-chain authority and I09's exact scale code path |
| P2 | Read-only PowerShell/Python scan of `data\game\var\envscales.cfg` | Independently recovered 26 `group =` headers (:5…:840), 122 `scale` literals, min=0.033 / max=1.02, minscale set `{0.85,1,0.95}`, maxscale set `{1.05,1,1.15}`, **zero `160` hits** |
| P3 | Read-only line reads of `createenvironemttest.inc:18-57`, `editor.aix:419-423`, `dogenerate.inc:2055` | Confirmed sole editor consumer, commented `scale` application (`:46-47`), comparison-copy-only min/max (`:48-57`), commented scale-fix generation call |
| P4 | `Get-FileHash` + token scan of I09 | Hash `C990F604…94B` = V59 subject hash ⇒ file unchanged. Tokens `envscales`, `minscale`, `maxscale`, `jitter`, `ENV_SCALE`, `FAMILY_SCALE`, `SCALE_` = **0 hits**; only `scale_contract` (`:474`) and `scale_authored` (`:752`). All `DONOR_UNITS`/`160` hits are negative strings in comments/strings |
| P5 | Read-only `field.prop:139-145`, `pattern.lib` literal scan, `generator.cfg` `160` scan | `field.prop:141-143` `0.03605085` vs `envscales.cfg:9` `0.033` (contradiction preserved); `pattern.lib:713429-713432` minegold `Scaling=0.315200001001358`; earlier hits at `:315640-315642` are a duplicated coordinate section (F08 R2), not a conflicting value; `generator.cfg` has 0 `160` hits |
| P6 | Guardrail decision pass against CHARTER §4 (:66-93), X57 §4/§6, V59 §7 | Classified all 26 groups editor-diagnostic-only; selected DEFERRED with no constants; verified no donor parity claim |

**Anomaly handled (P5):** the first three literal hits for `0.315200001001358` occur
at `pattern.lib:315640-315642`, not at F08's cited `:713429`. Second pass showed
`:315620` is another `BaseName = minegold` record — one of the 15 duplicated
section names in F08 R2 — while the `mng_1` record cited by F08 is at `:713410`
(`BaseName`) with `Scaling` struct at `:713429` and the X/Y/Z literals at
`:713430-713432`. Both are the same donor value; the accepted citation for the
skirmish `mng_1` stamp is `pattern.lib:713429-713432`. No contradiction promoted.

## 2. Full 26-group donor census (scale / minscale / maxscale) — [O]

Source: `data\game\var\envscales.cfg` (869 lines, SHA-256 per X57 E8
`5c3ac8f9…789f`), read-only this pass. The `group =` header line is given for
each row; the entry `name` line band is from pass P2. Scale values are in file
order. **[D] Observed minscale/maxscale pairs are only `(1,1)`, `(0.85,1.15)` and
`(0.95,1.05)` — no other pair exists in the 122 entries.**

| # | Group (`envscales.cfg:line`) | N | Entry line band | `scale` values (file order) | min/max |
|---:|---|---:|---|---|---|
| 1 | field (`:5`) | 1 | :8 | 0.033 | 1 / 1 |
| 2 | mines (`:16`) | 3 | :19-31 | 0.3152 ×3 | 1 / 1 |
| 3 | stones (`:40`) | 11 | :43-103 | 0.329, 0.329, 0.37, 0.4, 0.324, 0.313, 0.328, 0.25 ×4 | 0.85 / 1.15 |
| 4 | smallstones (`:111`) | 7 | :114-150 | 0.25, 0.209, 0.209, 0.236, 0.25 ×3 | 0.85 / 1.15 |
| 5 | fir (`:158`) | 5 | :161-185 | 0.5 ×5 | 0.85 / 1.15 |
| 6 | firsmall (`:193`) | 5 | :196-220 | 0.5 ×5 | 0.85 / 1.15 |
| 7 | pine1 (`:228`) | 5 | :231-255 | 0.475 ×5 | 0.85 / 1.15 |
| 8 | pinesmall1 (`:263`) | 5 | :266-290 | 0.55, 0.535, 0.56, 0.61, 0.5 | 0.85 / 1.15 |
| 9 | pinebroken1 (`:298`) | 5 | :301-325 | 0.64, 0.82, 0.69, 0.55, 0.5 | 0.85 / 1.15 |
| 10 | pinebrokenmoss1 (`:333`) | 5 | :336-360 | 0.64, 0.63, 0.705, 0.742, 0.5 | 0.85 / 1.15 |
| 11 | spruce1 (`:368`) | 5 | :371-395 | 0.5 ×5 | 0.85 / 1.15 |
| 12 | pinedry1 (`:403`) | 5 | :406-430 | 0.65, 0.618, 0.706, 0.76, 0.5 | 0.85 / 1.15 |
| 13 | pinestump (`:438`) | 5 | :441-465 | 0.91, 1, 0.817, **1.02** (`:460`), 0.817 | 0.85 / 1.15 |
| 14 | leaftree (`:473`) | 5 | :476-500 | 0.425 ×4, 0.504 | 0.85 / 1.15 |
| 15 | burch (`:508`) | 7 | :511-547 | 0.38, 0.374, 0.366, 0.341, 0.415, 0.434, 0.354 | 0.85 / 1.15 |
| 16 | burchstump (`:555`) | 5 | :558-582 | 0.807, 0.915, 0.807 ×3 | 0.85 / 1.15 |
| 17 | grass (`:591`) | 4 | :594-612 | 0.27 ×4 | 0.95 / 1.05 |
| 18 | grassforest (`:620`) | 4 | :623-641 | 0.475 ×4 | 0.95 / 1.05 |
| 19 | fern (`:649`) | 5 | :652-676 | 0.43 ×5 | 0.85 / 1.15 |
| 20 | drybushes (`:684`) | 5 | :687-711 | 0.5 ×5 | 0.85 / 1.15 |
| 21 | burdock (`:719`) | 4 | :722-740 | 0.356 ×4 | 0.85 / 1.15 |
| 22 | horseradish (`:748`) | 4 | :751-769 | 0.369 ×4 (name `horseradish.1` duplicated at `:757,:763`; `.2` absent — X57 C4) | 0.85 / 1.15 |
| 23 | chamomile (`:777`) | 3 | :780-792 | 0.147 ×3 | 0.85 / 1.15 |
| 24 | grasschamomile (`:800`) | 1 | :803 | 0.3 | 0.95 / 1.05 |
| 25 | plantain (`:811`) | 4 | :814-832 | 0.412, 0.417, 0.436, 0.384 | 0.85 / 1.15 |
| 26 | flowers (`:840`) | 4 | :843-861 | 0.281, 0.263, 0.29, 0.29 | 0.85 / 1.15 |

**[D] Coverage gap (X57 §2.3, re-confirmed):** none of the 26 groups names
`terrainmesh1..4`, `rocksea*`/`stonessea*`/`smallstonessea*`, `lily*`/`reed*`,
`pump*`/`gift*`/`christmastree*`, `palm*`/`desert*` or `terrainmeshdesert*`.
I09's relief, shore and decor classes therefore cannot derive a scale from this
table at all.

## 3. I09 current per-family scale handling — exact file:line comparison

All citations below are
`variant3d/scripts/terrain_donor_props.gd` (hash `C990F604…94B`, same file V59
audited; V59 §1 P8 hash drift from V36 is the already-landed `DONOR_UNITS` fix).

### 3.1 What I09 DOES have [O]

| Mechanism | Exact line | Meaning |
|---|---|---|
| `TILE_M := 2.0` | `:89` | horizontal world metres per cell, **placement only** (donor `dmscript.global:170-173`); not a prop-scale multiplier |
| `scale_contract` dict | `:474-481` | generator distance unit = 1 map cell; `horizontal_metres_per_cell = TILE_M`; `no_donor_units_multiplier = true`; `no_synthetic_scatter = true`; `visual_parity_claim = false`. **No prop-scale, min/max or jitter field exists in this contract** |
| Authoritative per-record `Scaling` read | `:657-659` | `_vec3(p_raw.get("Scaling", p_raw.get("scaling", null)))`, fallback `sx/sy/sz` |
| Non-finite guard | `:667-670` | `skipped_no_transform` if position/scale/yaw invalid |
| Scale stored on record | `:721` | `"scale": scale.x` — the authored uniform factor, one float |
| Provenance label | `:725` | `"DONOR LITERAL (Objects[])"` or `"PORT APPROX FALLBACK (Z08 table)"` |
| Uniform application | `:772-773` | `var sc := float(p_rec["scale"]); basis = basis.scaled(Vector3(sc, sc, sc))` — applied to the instance basis, no per-family multiplier |
| `scale_authored` meta | `:752` | marks the MultiMesh holder as using authored scale |
| Family statistics | `:706-709`, `:784-789` | track only `records`, `instances`, `sids`; **no scale, no jitter** |
| Forest family list | `:135-143` (`EXPECTED_FOREST_FAMILIES`) | 19 names only; no associated scale values |
| `UNVERIFIED_BASE` | `:147-173` | 27 entries; **no `envscales`/scale-table entry** |

### 3.2 What I09 does NOT have [O] — verified by full-token scan (P4)

- No `envscales` string, no `minscale`, no `maxscale`, no `jitter`, no
  `ENV_SCALE`/`FAMILY_SCALE`/`SCALE_` constant. The only `scale` tokens are
  `scale_contract` (`:474`) and `scale_authored` (`:752`).
- No per-family scale table, no family→multiplier dictionary, no min/max clamp on
  an instance scale, no seeded jitter draw. `transform_source` at `:725` and the
  `no_rng_draw` flag at `:442` explicitly forbid one.
- I09 is **render-only and currently inert**: V59 item 3 (Objects feed not wired,
  `pattern_lib_index.json` absent, `family_index.json` schema mismatch) and item 6
  (composer calls absent `bind()` at `terrain_donor_world.gd:229`, so `build()` is
  never invoked) are FAILs. Even a perfectly correct scale constant would have no
  live consumer until COORD repairs those two seams (V59 §9 items 1-2).

### 3.3 Head-to-head [D]

| Dimension | Donor `envscales.cfg` (26 groups) | I09 today | Consequence |
|---|---|---|---|
| Source authority | group-level *reference* multipliers on a prop's intrinsic `DefaultScale`; editor diagnostic | per-record `pattern.lib` `Objects[].Scaling` (`:657-659`) — F08 E10's authoritative source | I09 already reads the more authoritative field; the table is derivative |
| Mine scale | `0.3152`, jitter `1/1` (`:20-34`) | authored `0.315200001001358` via `mng_1` Objects record (`pattern.lib:713429-713432`) → `:721,:773` | Values agree; **no new constant adds information** |
| Jitter | 0.85/1.15 (23 groups), 0.95/1.05 (3 groups), 1/1 (2 groups) | none; authored scale applied exactly | `1/1` groups agree with no-jitter behaviour; the others would require a new RNG/clamp path the skirmish consumer does not have |
| Relief / shore / desert | absent from table | classes exist (`RELIEF_SIDS` `:130-132`, shore `:488-491`) but no scale source | table cannot fill the gap |
| Field | `0.033` (`:9`) | field hook is a closed-form plan with no instances (`:343-379`; V59 item 2); `field.prop:141` says `0.03605085` | contradictory, and no consumer |
| Runtime binding | editor-only, `scale` application commented | no scale table binding exists | no skirmish path to wire into |

## 4. Skirmish-relevance triage (X57 consumption finding applied)

X57 §4 splits consumption cleanly, and this pass re-verified both sides:

- **The registries are skirmish-relevant:** `objects.lib:51` loads `env.objects`;
  the env player exists in normal play (`player.script:639-640`, `init.script:231`)
  and skirmish relief stamps target it (`dogenerate.inc:398,1749-1766`). That is
  why I09's `Objects[]` scale path matters.
- **The scale table is not:** its only text reader is
  `createenvironemttest.inc:19-56`, an editor menu diagnostic
  (`editor.aix:420-422`); `scale` is read at `:38` but its application is commented
  at `:46-47`, and min/max are applied only to comparison copies at `:48-57`.
  `_misc_FixEnvironmentObjectsScales` exists (`misc.script:3805-3874`) but its
  generation call is commented at `dogenerate.inc:2055` (re-verified:
  `[*] = ;//_misc_FixEnvironmentObjectsScales(False); // optimize first`).
  All cited `.inc` lines are `[*] = ;` — activation **[U]**.

Triage of the 26 groups against that finding:

| Class (groups) | Skirmish-relevant scale source? | Table group status | Promote to hard constant? |
|---|---|---|---|
| Mines (group 2) | Yes — `pattern.lib` Objects `Scaling=0.3152` already consumed by I09 `:657-659,:721,:773` | Duplicate of authoritative value; jitter 1/1 | **No** — redundant; would create a second, divergent scale path |
| Conifers/leaf trees/weeds (groups 4-16, 19-26) | Yes — per-object `Scaling` in each `Objects[]` record (F08 §3.1 worked examples) | Group-level summary with jitter factors; no runtime consumer | **No** — jitter path is editor-only and I09 forbids RNG draws (`:442`) |
| Stones / smallstones (groups 3-4) | Yes — per-object `Scaling` in `d_stn_*`/`str_new_*` records (F08 §3.2) | Same as above | **No** |
| Field (group 1) | No instance consumer in I09; script-sown per spec/08 §8 | Contradictory literal `0.033` vs `0.03605085` | **No** |
| Relief / shore / desert / decor | Classes exist but no group in the table | Coverage gap | **No** — nothing to promote |

**Result: 0 of 26 groups qualify.** No group has a demonstrated skirmish runtime
consumer, and every group that overlaps a skirmish class already has a more
authoritative per-object source in the path I09 uses.

## 5. Preserved contradictions (reasons NOT to harmonise or promote)

- **[O] C3 (X57):** `envscales.cfg:9` `scale = 0.033` vs `field.prop:141-143`
  `DefaultScale X=Y=Z=0.03605085`, `RandomScale = False` at `:145`
  (re-verified this pass). Reason for the difference **[U]**; both literals are
  preserved, neither overwrites the other.
- **[O] C4 (X57):** `horseradish.1` appears twice (`envscales.cfg:757,:763`),
  `horseradish.2` absent although `env.objects:142` registers
  `horseradish2.prop`. A genuine donor typo in a diagnostic table — not a
  constant worth cloning.
- **[O] X57 §6.1 caution:** `plantain3.prop:80-82` has `X=Y=0.384, Z=0.288` and
  jitter `0.925/1.075` (`:85-86`), while `envscales.cfg:832` gives a single
  `0.384` with `0.85/1.15`. The table is a **reference summary**, not a
  byte-exact mirror of `scaleproperty`. Binding a single instance from it would
  diverge from the prop's own authored scale.

## 6. `DONOR_UNITS=160` reintroduction check — **PASS (none)** [O]

Full-token scan of `terrain_donor_props.gd` (P4) returned only these lines, every
one a *negative* declaration, never a numeric assignment or division:

| Line | Text (verbatim) | Effect |
|---|---|---|
| `:24-25` | "`DONOR_UNITS=160`, `s = MAP_W/160`, '1 unit = 2 cells' is **REFUTED** by V08 …" | comment |
| `:88` | "`DONOR_UNITS=160 / s=MAP_W/160` is REFUTED — removed deliberately (V08 :40-51, E23 :142)" | comment |
| `:467` | `"unit": "MAP CELLS 1:1 — no DONOR_UNITS=160 multiplier (V08 C1)"` | string in stats |
| `:478` | `"no_donor_units_multiplier": true` | boolean flag in `scale_contract` |
| `:578` | `"donor_units"` in a list of feed keys to **skip** during feed scanning | metadata key, no value |
| `:634` | "V08 C1: donor Position/footprints are MAP CELLS 1:1 — **no W/160**, no x2" | comment |

**[O] Donor-side negative:** 0 occurrences of `160` in
`data\game\var\envscales.cfg` and 0 in `data\game\var\generator.cfg` (P2/P5).
Nothing in the 26-group table supports a cell↔world divisor; X57 §6.3 remains
**DEFERRED** to COORD/I09 and this worker issues no value. The only numeric scale
in I09 is `TILE_M := 2.0` at `:89`, documented as placement-only metres/cell
(V08 C2) — untouched.

## 7. Determination and hand-off

1. **[O]/[D] DEFERRED — no new constants.** Do **not** add an `ENV_SCALE_*`,
   `MINE_SCALE`, `STONE_SCALE`, jitter or min/max table to
   `terrain_donor_props.gd`. The table's sole consumer is an editor diagnostic
   whose `scale` application is commented; promoting its literals would violate
   CHARTER §4's "No invention. No new donor constants" (:83-84) and would
   duplicate the authoritative `Objects[].Scaling` path I09 already uses.
2. **[O] No paste-ready GDScript constant block is issued.** A block would be
   actionable only if a skirmish caller were demonstrated (none exists) and if
   I09 lacked a per-object source (it has one at `:657-659,:721,:773`). Even then
   the correct citation would be the per-record `pattern.lib` `Objects[]` value,
   not the group summary.
3. **[O] The real I09 blockers are unchanged from V59 §9:** (a) repair the
   composer→I09 adapter so `build()` is called (`terrain_donor_world.gd:228-231`);
   (b) wire the I03 `families/*.json` `Objects[]` feed into `_normalize_record`
   via a new branch, labelling `transform_source = "DONOR LITERAL (I03 Objects[])"`
   and preserving `skipped_no_transform`. **Neither requires an envscales
   constant.** When (b) lands, mine/stone/tree scales arrive with the records
   (e.g. `mng_1` `minegold` `0.3152`), making an envscales table redundant.
4. **[U] Keep these UNVERIFIED, do not promote:** runtime role of `envscales.cfg`
   outside the editor tool; activation of every `[*] = ;` line; the `0.033` vs
   `0.03605085` field discrepancy; the `horseradish.2` absence; any cell↔world
   divisor; all visual parity.

## 8. Claim register

| # | Claim | Evidence | Label |
|---:|---|---|---|
| 1 | 26 groups / 122 entries; scale 0.033–1.02; min/max only (1,1)/(0.85,1.15)/(0.95,1.05) | §2 census, P2 | [O]/[D] |
| 2 | Sole text consumer is an editor diagnostic; `scale` application commented; min/max only on comparison copies | `createenvironemttest.inc:19-56`, `editor.aix:419-423`, X57 E9/E15/C5, P3 | [O]/[U] |
| 3 | I09 has no scale table, jitter or min/max; scale comes from per-record `Scaling` and is applied uniformly | props `:657-659,:721,:725,:772-773`; P4 token scan | [O] |
| 4 | 0 of 26 groups should be promoted; DEFERRED, no constants issued | CHARTER §4:83-84; X57 §4/§6; §3-§5 above | [D] |
| 5 | Authoritative mine scale already present in `pattern.lib:713429-713432` and consumed by I09 | P5; props `:657-659,:721,:773`; F08 E13 | [O] |
| 6 | No `DONOR_UNITS=160` reintroduction; donor files also contain no `160` | §6 table; P2/P5 | [O] |
| 7 | I09 file unchanged from V59 snapshot; no parity claim; no repo file edited but this report | hash `C990F604…94B`; scope_guard | [O] |

---
*End of X70. Exactly one report written. Donor READ ONLY; no binary executed,
copied or committed; no Godot job, gate, capture, source, shader, config, asset,
test or git change. NO DONOR PARITY CLAIM.*
