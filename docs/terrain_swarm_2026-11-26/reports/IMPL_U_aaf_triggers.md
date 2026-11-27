---
id: IMPL-U-AAF-TRIGGERS
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER IMPL-AAF-TRIGGERS — HARD implementation of the statically resolved donor trigger facts in anim3d.gd"
owner_file: docs/terrain_swarm_2026-11-26/reports/IMPL_U_aaf_triggers.md
status: DELIVERED__CODE_ANIM3D_ONLY__ONE_REPORT__STATIC_CHECK_ONLY__NO_GODOT_RUNNER_GIT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION, NO_WEAKENED_TEST, STATIC_CHECK_ONLY]
source_decision: docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md
files_written:
  - variant3d/scripts/anim3d.gd
  - docs/terrain_swarm_2026-11-26/reports/IMPL_U_aaf_triggers.md
backup: variant3d/scripts/anim3d.gd.bak-AAFTRIG
parity_guard: "NO DONOR PARITY IS CLAIMED. No donor frame, no donor/port A/B and no runtime capture was produced or examined by this worker. Every donor statement below is a read-only file/line observation from DEC_U_aaf_triggers.md; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly two repo files written: variant3d/scripts/anim3d.gd and this report. NOT world3d_entities.gd (owned by IMPL-BUILDING-DEATH), NOT data.gd/game.gd (owned by IMPL-SKIRMISH-ROWS), NOT terrain/water files, NOT assets/config/tests/fixtures. No Godot, no runner, no git, no donor binary executed, no donor bytes copied. Static-check only (delimiter/function audit). Singleplayer skirmish only."
---

# IMPL-U — AAF trigger/completion/blend facts into `anim3d.gd`

> READ-ONLY donor facts, HARD-scoped HDS implementation. No parity claim. No approximation. No weakened test.
> Labels follow `DEC_U_aaf_triggers.md` §0: `[O]` observed donor/port line, `[D]` arithmetic over `[O]`, `[I]` reading without runtime proof, `[U]` unresolved with a named capture.
> Path shorthands: `P:` = workspace `variant3d\`; donor cites are carried verbatim from `DEC_U_aaf_triggers.md` and were **not** re-read or re-executed here.

## 0. Scope, backup and preserve-mod proof

| Item | Value [O] |
|---|---|
| Scoped editable file | `P:scripts/anim3d.gd` — the ONLY source file written |
| Report written | `docs/terrain_swarm_2026-11-26/reports/IMPL_U_aaf_triggers.md` — the ONLY report written |
| Backup | `P:scripts/anim3d.gd.bak-AAFTRIG` created by byte copy BEFORE the first edit |
| Pre-edit `anim3d.gd` SHA256 | `DE1DDB4D63610C8D9292FE77FA57960FC86BF764BF779BFC0010168CA14D23E2` |
| Backup SHA256 (identical) | `DE1DDB4D63610C8D9292FE77FA57960FC86BF764BF779BFC0010168CA14D23E2` — **preserve-mod proof: backup is byte-identical to the pre-edit file** |
| Post-edit `anim3d.gd` SHA256 | `D34AB1809A320E4CAD5D17C798A58E92CE7B290CAE7E53E56475A8F1188E3DAC` |
| Pre/post line counts | 1191 → 1519 lines (all changes are additions plus one signature extension; see §1) |
| `world3d_entities.gd` | **NOT written by this worker.** No `edit`/`write`/shell-write call targeted it. Its current line anchors for §5 were re-read read-only after a concurrent owner edit. |
| `data.gd` / `game.gd` / terrain / water / assets / config / tests | Not written, not opened for edit |

**Preserve-mod proof:** every pre-existing `func` in the backup is still present in the edited file with the same name and body except `_frame_blend_fields`, whose signature was extended by one *optional* parameter and whose returned Dictionary gained three *additional* keys (all existing keys unchanged). No pre-existing constant, citation string, label, status string, cache, or behaviour path was deleted, weakened, or redirected. `play()`, `pose_for()`, `action_info()`, `_frame_at()`, `_is_once_action()`, `_is_attack_action()`, `_action_range_for()`, `_unknown()` are byte-identical to the backup.

## 0.1 Static-check evidence (no Godot/runner/git; delimiter/function audit only)

A Python 3.14 source scanner (masked strings + comments, then balance scan) plus `difflib` against the backup produced:

```
BRACE_AUDIT: OK                 # {}, (), [] all balanced; no unmatched close; no unclosed open
FUNC_COUNT: now=47 backup=35    # 35 + 12 added = 47
DUP_FUNCS: none
REMOVED_FUNCS: none
ADDED_FUNCS: donor_trigger_row, donor_row_token, _donor_sticky_idle,
             resolve_donor_trigger, resolve_donor_action, donor_cycle_policy,
             frame_blend_for_trigger, set_aaf_completion_hook,
             has_aaf_completion_hook, aaf_completion_probe,
             is_donor_orphan_token, donor_orphan_note
TRIGGER_ROWS: T1..T26 (exactly, in order)
ROWS_T1_T26_EXACT: OK
PRESERVE_EXISTING_FUNCS: OK
LINES: now=1519 backup=1191
```

`difflib` opcode audit shows exactly six changed regions (§1) and no others. **No parse/compile/run was attempted** — this worker has no Godot/runner authority; runtime verification stays with the owner and is not claimed.

## 1. Exact changed lines (`P:scripts/anim3d.gd`)

All line numbers are **post-edit**. No line outside these six hunks differs from `anim3d.gd.bak-AAFTRIG`.

| # | Hunk | Post-edit lines | Change |
|---|---|---|---|
| 1 | Insert new donor-fact const block after `FRAME_BLEND_STATUS` | **139–236** | 98 new lines/comment lines: `DONOR_BLEND_NONE/MINMAX/SITES` (160–162), `DONOR_CYCLE_SITES` (175), `AAF_COMPLETION_STATUS` (179), `DONOR_ORPHAN_TOKENS` (186–193), `DONOR_ORPHAN_PREFIXES` (195), `AAF_ORPHAN_STATUS` (196), `DONOR_TRIGGER_TOKENS` T1–T26 (208–234) |
| 2 | Insert empty completion-hook var in var block | **264–267** | `var _aaf_completion_hook: Callable = Callable()` (267) with `[U]-C1/C2` comment |
| 3 | Extend `_frame_blend_fields` signature | **870** | added optional `requested_blend: String = DONOR_BLEND_MINMAX` — all existing 2-arg callers unaffected |
| 4 | Insert intent-only blend comment + `bypass` local | **872–875** | `var bypass: bool = requested_blend == DONOR_BLEND_NONE` |
| 5 | Add three returned keys to `_frame_blend_fields` | **882–884** | `requested_blend`, `requested_blend_sites`, `blend_bypass` |
| 6 | Append resolver/API section after `_publish()` | **1301–1519** | 12 new functions listed in §0.1; no existing function touched |

**Not changed:** `AAF_ACTIONS`, `ACTION_ALIAS`, `ACTION_ALIAS_STATUS`, `AAF_LOOP_STATUS`, `DONOR_MIN/MAX_FRAME_BLEND`, `FRAME_BLEND_STATUS`, `AAF_ATTACK_TOKENS`, `POSE_KEY`, all skin/parse/cache/shipped-skin code, all of `play()`/`pose_for()`/`_frame_at()`/`_is_once_action()`/`_is_attack_action()`/`_action_range_for()`/`_unknown()`/`_publish()`.

## 2. What was implemented

### 2.1 Donor trigger→AAF token resolver, per-site blend, existence gate (T1–T26)

`DONOR_TRIGGER_TOKENS` (`anim3d.gd:208–234`) carries **all 26 rows of DEC-U §1.2** verbatim as read-only data. Each row stores five donor facts plus two carry-over labels:

- `token` — the concrete AAF token(s) emitted `[O]`; a Dictionary when a decoded tag field selects (resource for T1–T3, weapon for T21, idle/turn/walk for T14–T17), a String otherwise, an Array for T22's child-visibility swap (explicitly *not* an AAF token).
- `blend` — `DONOR_BLEND_NONE` (`"0,0"`) or `DONOR_BLEND_MINMAX` (`"6,8"`) `[O]`; a `{turn,idle,walk}` Dictionary where the donor defers the choice (T8/T10/T12 carry idles, T14–T17 weapon-state rows).
- `gate` — the donor existence-gate citation `[O]`, e.g. `_unit_IsAnimationExists unit.script:10888` (T1–T7), `animidle → gc_anim_idle :11036-11037` (T8/T10/T12/T18–T20), `weapon token → plain death :11092-11093` (T21).
- `cite` — donor set-site `path:line` `[O]`; orphan rows instead record the *zero-hit search* evidence (`ev_P5a–d`).
- `port` / `orphan` / `note` — carried port-read status, explicit orphan flag, and the donor caveat (dead `walk1` name, readback-only states, no grenade-order proof, artillery reload/desync, tool prop `[U]-T`).

Public API (all additive, §1 hunk 6):

| Function | Line | Contract |
|---|---|---|
| `donor_trigger_row(id)` | 1310 | returns the row Dictionary or `{}` — never fabricates a row |
| `donor_row_token(row,key)` | 1320 | resolves a concrete token; Array token (T22) returns `""`, never a substitution |
| `resolve_donor_trigger(fields)` | 1356 | decoded tag fields → `{ok, trigger_id, token, blend, gate, cite, orphan, port, note, completion, cycle_sites, blend_sites, visual_hide}` |
| `resolve_donor_action(sid, fields)` | 1432 | same + **existence gate**: `available = token != "" and has_action(sid, token)` (the runtime mirror of `_unit_IsAnimationExists`, `unit.script:369-373`); a miss is annotated `HAS_ACTION_MISS`, never silently substituted |

Branch order in `resolve_donor_trigger` is the donor's own by cited line number: `iVisual=hide` T26 (`:11076-11080`) → `iEssential=death` T21 (`:11086-11103`) → extract T1–T3/build T4/attack T5–T7 (`:10865-10882`) → carry T8–T13 (`:10901-10919`) → weapon-state T14–T17 (`:10928-10954`) → sticky readback T18–T20 (`:10977-11029`). **No entity state is read**; `fields` must be supplied by the caller (see §5). Sticky readback is honoured *only* when the caller explicitly supplies `current_anim`; off by default.

Rows with no donor set-site (T23 `attack2before/after`, T24 `reaction`, T25 `prepare*/trans*` readback-only) return `token = ""`, `orphan = true`, and a cite naming the zero-hit search. **No selector or fallback is invented for them** — the only path remains the caller's explicit `anim_action` request (§5, F7).

### 2.2 Loop vs clamp-once policy (DEC-U §2)

`DONOR_CYCLE_SITES` (`anim3d.gd:175`) carries the exact sources named in the assignment:

- `showdebuganimations.inc:45-66,113-156` — `bPlayOnce=False` (loop: `walk/walk0`, `idle/idle0/idle1/idle2`, `construct`, `work*`, carry*), `bPlayOnce=True` (once: `attack0/1/2`, `death/death0/death1`; `:121-123,129-131`).
- `movie.script:648-656` — `bLoop→acmLoop`, `bOnce→acmPlayOnce`, else `acmNone`.
- `unit.script:10808-10809,10852` — `DoDeath` `acmPlayOnce/aamPlayOnce`; `visual_stage_0` `acmPlayOnce`; `unit.script:11076-11080` hidden `acmNone/aamNone`.
- `cannon.acl:33-45` — `attack0/attack1` `CyclesList=False` + `NumberCycle=1` bracketed by `OnAclAnimationReachedAttack / …AttackEnd`.

`donor_cycle_policy(action)` (`anim3d.gd:1449`) returns the donor mode plus the existing port cycle word (`once_clamp` from `_is_once_action`/`_frame_at`, already in place from IMPL-AAF-ART). The debug menu's dual-listed attack buttons (loop *and* once at `:125-127`) are recorded in the comment: the **sim** path is once. The `acmNone` mode is documented but **no hide path is wired** (T26 port status `no`) — no port state is invented for it.

### 2.3 `min/maxFrameBlend = 6/8`, exact sites, `0,0` bypass, `[U]-B` left open

`DONOR_BLEND_NONE` / `DONOR_BLEND_MINMAX` / `DONOR_BLEND_SITES` (`anim3d.gd:160–162`) carry:

- **literal**: `unit.script:10846-10847` (`minFrameBlend=6`, `maxFrameBlend=8`, per-evaluation locals in `_unit_ForceStateTag`).
- **install**: `initial.inc:17-19` (`SetGameObjectMinFrameBlendByHandle(6)`, `Max…(8)`, `DeferredFrameBlend(false)`).
- **consume**: `unit.script:10970,11016,11055,11100` + `ontagstates.inc:474,513,596` (`GameObjectSwitchToTreeAnimationCyclesBlendByHandle(..., minFrameBlend, maxFrameBlend)`).
- **`0,0` bypass**: `unit.script:10891-10893` (`bSkip` early-out, "dont use blend cause it kills animation") and `:11042` (idle re-entry, "to reset blend … needed to prevent 2 shooting animation effect"), mirrored at `ontagstates.inc:329-343`. Artillery death reuses `min/max` then `GameObjectResetFrameAnimationBlend` (`:11100-11102`).

`_frame_blend_fields` (`anim3d.gd:870`, 872–875, 882–884) now logs the donor call-site intent through a new optional parameter: `requested_blend` (`"0,0"` vs `"6,8"`), `requested_blend_sites`, and `blend_bypass`. `frame_blend_for_trigger()` (`anim3d.gd:1468`) exposes the per-call passthrough from a T-id. **No interpolation is performed**; the existing `FRAME_BLEND_STATUS` / `_nearest_exported_frame` nearest-frame diagnostic and `DONOR_MIN/MAX_FRAME_BLEND = 6/8` are unchanged. The engine operator stays **`[U]-B`** with capture **R-B** (§6). A split `{turn,idle,walk}` blend reduced without a `move` tag falls back to the *cited donor* `"6,8"` default — never an invented number.

### 2.4 Orphan tokens stay explicitly labelled — no invented selector/fallback

`DONOR_ORPHAN_TOKENS` (`:186–193`), `DONOR_ORPHAN_PREFIXES` (`:195`), `AAF_ORPHAN_STATUS` (`:196`), `is_donor_orphan_token()` (`:1505`) and `donor_orphan_note()` (`:1514`) name, respectively:

| Token family | Label carried | Donor fact `[O]` |
|---|---|---|
| `reaction` | orphan, no set-site | AAF `peaukr.aaf:18 [456,481]`; zero refs in `unit.script`, `D:scripts/**`, `D:animations/acl/**`; no `gc_anim_reaction` constant (`ev_P5a/P5d`); `[U]-R` |
| `attack2before` / `attack2after` | orphan, no set-site | AAF grenadier `630..663 / 664..679`; debug buttons only (`showdebuganimations.inc:123,127`); `[U]-W` |
| `walk1` | donor-dead name | selected at `unit.script:10946` but zero AAF rows in the 246-file census; degrades to `walk` at `:11048-11051` `[D]`; **never request** |
| `prepare*/unprepare*/trans*/walkprepare*/walkunprepare*` | readback-only prefix family | T25: no `anim :=` set-site (`ev_P5c`); ACL-driven; `[U]-A` |
| `turn*/collide*` | vocabulary-only prefix family | `dmscript.global:868-926` constants; no AAF rows; turning uses rotate calls (`ev_P3a/P2d`) |

`is_donor_orphan_token()` only **classifies**; it does not select. `donor_row_token()` returns `""` for these rows. The only port path remains explicit, availability-gated, gap-recorded `anim_action` (§5 F7).

### 2.5 Completion signals stay `[U]-C1/C2`

`AAF_COMPLETION_STATUS` (`:179`) records DEC-U §3.2: no armed non-empty `OnStateEndCyclesReached` / `OnStateFBEndCyclesReached` / `OnStateEndFrameReached` handler on the unit path (`unit.script:10811-10815` clears all four); death completion is the delayed `DeathStage1` state (`:11085`); attack completion is ACL-bracketed (`cannon.acl:33-45`, `…AttackEnd` body unreadable). The clamp-at-last-frame in `_frame_at` remains a **labelled stand-in** under `AAF_LOOP_STATUS`.

The empty hook registry `_aaf_completion_hook` (`:267`) plus `set_aaf_completion_hook` (`:1482`), `has_aaf_completion_hook` (`:1486`) and `aaf_completion_probe` (`:1493`) are a **registration point and log site only**. Nothing calls them from `play()`/`pose_for()`/`_frame_at()` while `[U]-C1/C2` are open; no completion event is fabricated. Captures R-C1/R-C2 must land before any hook is fired.

## 3. Compact T1–T26 disposition (all rows are `[O]` DEC-U §1.2)

| Row(s) | Donor trigger → token | Blend `[O]` | Existence gate `[O]` | Resolver line |
|---|---|---|---|---|
| T1/T2/T3 | extract+food/wood/stone → `workfood/workwood/workstone` | `0,0` | `_unit_IsAnimationExists :10888` | 209–211 |
| T4 | build → `construct` | `0,0` | `:10888` | 212 |
| T5/T6/T7 | attack+`iWeapon` {none,0}/1/2 → `attack0/1/2` | `0,0` | `:10888` | 213–215 |
| T8–T13 | carry res × idle/turn vs walk → `idle{res}` / `walk{res}` | turn/idle split `6,8`/`0,0`; walk `6,8` | `animidle→idle :11036-37`; `animwalk→walk :11048-51` | 216–221 |
| T14–T17 | `iWeapon` none/0/1/2 × idle/turn/walk → `idle*/walk*` | `0,0` idle; turn `6,8`; walk `6,8` | same sticky/walk fallbacks | 222–225 |
| T18–T20 | sticky readback → `idle0/idle1/idle2` | turn `6,8` / idle `0,0` | `animidle` re-check `:10987-88,11036-37` | 226–228 |
| T21 | death × weapon → `death/death0/death1/death2` | `6,8` (+ artillery reset+reload) | weapon → plain `death :11092-93` | 229 |
| T22 | peasant tool swap → `hoe/axe/pick/hammer/bag/lumber/cart/hide` | n/a | usage+child count `:11068` | 230 |
| T23/T24/T25 | `attack2before/after`, `reaction`, `prepare*/trans*` | n/a | **no set-site** — explicit request only | 231–233 |
| T26 | `iVisual=hide` → `DoDeath` + `acmNone/aamNone` | n/a | visibility, no AAF token | 234 |

## 4. Deliberately NOT done (scope and [U] discipline)

1. **No entity-state→token selection in `world3d_entities.gd`.** That file was not edited; the exact patch recommendation is §5.
2. **No sim-field decode.** `resolve_donor_trigger(fields)` accepts already-decoded `iAction/iWeapon/iMove/iResource/iEssential/iVisual` (`unit.script:10837-10843`); this worker does not invent a decoder from port entity dictionaries.
3. **No interpolation, no invented frame, no donor parity claim.** `[U]-B` stays open; nearest-frame diagnostic unchanged.
4. **No completion event fired.** `[U]-C1/C2` stay open; hook registry empty.
5. **No auto-trigger for orphans** (`reaction`, `attack2before/after`, `prepare*/trans*`, `turn*/collide*`, `walk1`); no selector and no fallback invented.
6. **No Godot/runner/git.** Static delimiter/function audit only (§0.1). No test weakened; no new test asserted as passing.

## 5. Exact patch recommendation for `variant3d/scripts/world3d_entities.gd` (NOT applied here)

> Owner file is `IMPL-BUILDING-DEATH`. Line anchors below were re-read read-only at 2026-11-26 ~20:26 after a concurrent owner edit; re-anchor before applying. This section is a **recommendation**, not an implementation. No asset needed; all named clips are exported per IMPL-AAF-ART C1.

**R1 — decode tag fields and call the resolver.** At `world3d_entities.gd:3208` (`var action := _unit_action(ed, speed)`), replace the single call with the resolver path, keeping `_unit_action` as the labelled port fallback chain until the captures land:

```gdscript
		var action := _unit_action(ed, speed)
		# DEC-U-AAF-TRIGGERS: donor-fact resolver + per-sid existence gate.
		# `fields` must be decoded from the sim's own order/entity state by the
		# OWNER of this file — no decoder is invented by anim3d.gd. The resolver
		# never substitutes an orphan token; a miss stays a labelled gap.
		var anim_resolver = _find_anim()
		if anim_resolver != null and anim_resolver.has_method("resolve_donor_action"):
			var tag_fields := _donor_tag_fields(ed, speed)   # OWNER TO IMPLEMENT
			var resolved: Dictionary = anim_resolver.call("resolve_donor_action", sid, tag_fields)
			if bool(resolved.get("available", false)) and str(resolved.get("token", "")) != "":
				action = str(resolved["token"])
				# intent-only: no interpolation, per DEC-U §7 F3 / [U]-B
				var blend := str(resolved.get("blend", "6,8"))
				# pass `blend` to the pose call below when the owner adds the
				# optional blend parameter; do NOT interpolate on it.
```

**R2 — tool/resource/weapon → tags.** Add `_donor_tag_fields(ed, speed) -> Dictionary` near `_donor_resource_suffix()` (`world3d_entities.gd:1954`) mapping the sim's order type / carry / weapon-slot **index** onto `iAction` (`extract/build/attack`), `iResource` (reuse `_donor_resource_suffix`), `iMove` (`walk` iff `speed >= WALK_SPEED_GATE_M_S`), `iWeapon` (slot index 0/1/2), `iEssential` (`death` iff `ed.dead`), `iVisual` (hide iff a hide tag exists). **Weapon-slot index proof is `[U]-W`** — keep `_weapon_kind()` (`:1971`, `kind=="bullet"`) as a labelled fallback, never delete it before R-W lands. Do **not** map a grenade order to `iWeapon=2` until R-W produces one.

**R3 — death by weapon (DEC-U §7 F5).** At `world3d_entities.gd:1860-1861` (`if ed.dead: return "death"`), branch `death0/death1/death2 → death` by the same weapon-slot index, availability-gated through `_donor_action_fallback()` (`:1943`). Record the attempted order in `_record_action_gap()` (`:1982`). `[U]-W2` remains open until R-W2 lands; never claim the weapon split is proven.

**R4 — carry order and dead name (DEC-U §7 F6).** At `:1896-1907`, preserve `work*`-first for stationary gathering (already correct); **never request `walk1`** (donor-dead name, D2) in any chain; add the `animidle`-existence re-check before returning carry idles, mirroring `unit.script:11036-11037`.

**R5 — orphan allow-list (DEC-U §7 F7).** At `:1871-1879`, keep explicit `anim_action` as the **only** path for `reaction / attack2before / attack2after / prepare* / trans*`. Add a comment naming T23–T25 as orphan-only until R-R/R-A/R-W land; document in `_action_available()` (`:1930`) that an empty request is a no-op, not `idle` (mirror `_unit_IsAnimationExists` `'' → true`, `unit.script:369-373`).

**R6 — sticky readback (DEC-U §7 F8).** At `:1926` (`return "walk" if moving else "idle"`), keep the stateless return. A one-slot `last_anim` name-only sticky readback with the T18–T20 map may be added **only after** capture R-S proves dwell; anim3d's `_donor_sticky_idle()` classifier is available but dormant by default.

**R7 — gap chains (DEC-U §7 F9).** Extend `_record_action_gap()` (`:1982`) to record the *chain as tried* (walk `animwalk→walk` `:11048-11051`; death weapon→`death` `:11092-11093`; sticky `animidle→idle` `:11036-11037`) so R-W/R-W2/R-S can audit which link fired. No silent substitution (already the behaviour).

**R8 — alias reverse guard (DEC-U §7 F1).** No asset/code change needed in anim3d.gd: `ACTION_ALIAS` is a port bridge only. New callers must route through R1; reject a bare `"attack"` from any new caller via the existing `sid_unknown` path (`anim3d.gd:1265–1291`).

## 6. Remaining `[U]` register and named experiments (all carried from DEC-U §6; none closed here)

| `[U]` | What is missing | Named capture / termination |
|---|---|---|
| `[U]-B` | Engine meaning of `6/8` (frames? look-ahead? weights?) | **R-B**: walk→idle seam (`peaukr walk 1..20 → idle 64..113`) stepped 1 frame/tick; render vertex hash for ticks `[-2,+10]` under `min/max` vs forced `0,0`; fit step-response length, 3 trials; else log non-reproducibility. Until then nearest-frame diagnostic only. |
| `[U]-C1` | Engine action at last frame of `attack*/death*` under `acmPlayOnce` | **R-C1**: musketeer `attack1 [99,124]` single shot, 30 Hz trace `t0..t0+span+10`; hold at 124 vs snap to `idle1 [256,305]` vs mid-blend freeze; repeat peasant `death [115,149]`; verdict with tick numbers, 3/3 trials. |
| `[U]-C2` | Effects bound to `OnAclAnimationReachedAttackEnd` | **R-C2**: cannon `attack0/attack1 [301,337]` on fixed camera; log muzzle-flash PFX frame, damage tick, sound tick relative to `301..337`; 3-trial offsets or absence log. |
| `[U]-W` | `kind=="bullet"` ⇔ donor `iWeapon=1`; any `iWeapon=2` order | **R-W**: musketeer/grenadier fixed camera, ground+unit targets; log `iWeapon`, `selected_anim`, frame trace `0..span+2`; `attack1` iff `iWeapon=1` ≥3/3 per sid AND `attack2before→attack2after` on grenade order (or absence + order scale logged). |
| `[U]-W2` | Live `iWeapon≠none` at death; fallback visible | **R-W2**: armed (musketeer `death0 564..628`) vs unarmed (peasant `death 115..149`); log `iWeapon`, `selected_anim`, `0.7+random*0.6` factor; weapon-death token ≥2/2 armed with fallback logged. |
| `[U]-S` | Engine-visible dwell of `prepare*/trans*/attack*` names | **R-S**: 90-tick 30 Hz log of `GetGameObjectFrameAnimationNameByHandle` across musketeer attack→idle; sticky name ≥1 tick with count, or 3 clean seams with zero intermediates. |
| `[U]-A` | Triggers entering `prepare*/trans*/walkprepare*` clips | **R-A**: stance toggles, formation joins/leaves, cavalry mount/dismount on fixed camera; one reproducible trigger per family or explicit absence log. |
| `[U]-R` | `reaction` trigger | **R-R**: raids/deaths nearby/combat start-end/construction complete/idle ≥120 s with full tag dump; one reproducible trigger with tag fields or absence logged across battery (token stays export-only). |
| `[U]-T` | Peasant tool `.oss` bone tracks / attach mode | Glob `D:actors/**/*pea*`, `*tool*`, `*attach*`; if absent, close-up capture of work/carry/construct logging `_unit_ManagePeasantAttach` handle + visible tool per action. (Owned by art lane; carried here because T22 is in the table.) |

Every capture is fixed-camera, singleplayer skirmish, paused-then-stepped, with per-frame `(sim_tick, tag_fields, selected_anim, AAF first..last, requested_frame, sample_frame, blend_delta, within_window)`. **This worker executed none of them.**

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Backup byte-identical to pre-edit `anim3d.gd`; exactly 2 repo files written | `[O]` SHA256 + `difflib` §0/§1 |
| 2 | T1–T26 rows present verbatim, in order, with token/blend/gate/cite/port/orphan/note | `[O]` `anim3d.gd:208–234`; source DEC-U §1.2 |
| 3 | Resolver is pure: no entity-state read, no orphan selector, no substitution; existence gate = `has_action(sid,token)` | `[O]` `anim3d.gd:1310–1446` |
| 4 | Loop/once cites exactly `showdebuganimations.inc:113-156`, `unit.script:10808-10852`, `movie.script:648-656`, `cannon.acl NumberCycle=1` | `[O]` `anim3d.gd:175,1449–1464` |
| 5 | `6/8` literal/install/consume sites + donor-proven `0,0` bypass carried; intent-only passthrough added; no interpolation | `[O]` `anim3d.gd:160–162,870–884,1468–1478` |
| 6 | Orphans labelled (`reaction`, `attack2before/after`, `walk1`, `prepare*/trans*` readback-only, `turn*/collide*` vocabulary-only) | `[O]` `anim3d.gd:186–196,1505–1518` |
| 7 | Completion hook empty; clamp-at-last still `[U]-C1/C2` stand-in | `[O]` `anim3d.gd:179,267,1482–1502` |
| 8 | Static delimiter/function audit OK; 0 removed funcs, 0 duplicate funcs, balanced braces | `[O]` §0.1 |
| 9 | `world3d_entities.gd` patch recommendation is a recommendation only; file not written by this worker | `[O]` §5 + scope guard |
| 10 | All nine `[U]` keep named captures; none closed by a port fallback | `[D]` §6 + DEC-U §6 |
| 11 | Any port motion/timing/blend equal to donor, or any orphan auto-trigger, or any runtime/test PASS claim | **Denied** — no donor A/B, no runner, no capture in this worker |

## 8. Scope statement

Exactly two repository files were written by this worker: `variant3d/scripts/anim3d.gd` and this report. The backup `variant3d/scripts/anim3d.gd.bak-AAFTRIG` is a byte-identical copy of the pre-edit file. No donor binary was executed and no donor bytes were copied; all donor facts are carried read-only from `DEC_U_aaf_triggers.md`. No Godot, runner, git, asset, config, fixture, test or user-mod state was touched. `world3d_entities.gd` was not edited; §5 is an exact patch recommendation for its owner. No parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer is out of scope.

*End of IMPL-U-AAF-TRIGGERS.*
