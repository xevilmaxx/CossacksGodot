---
id: NATION-SPAWN-IMPL-01
owner: NATION-SPAWN-IMPL-01 implementation subagent
date: 2026-11-25
status: IN PROGRESS — code edit landed; smoke gate green; sid-dump probe queued
scope: "Exactly two repo files touched: variant3d/scripts/game.gd (edited) and this report (written). Backup written to inbox/backup/game.gd.bak-NATIONSPAWN01. NO other repo file edited — not data.gd, world3d_entities.gd, tests, config, app/**, board or any selftest/uitest artifact. Variant runner only; no direct godot invocation; no queue mutation; no re-submit."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = literal bytes/artifact read this pass | derived = arithmetic/control-flow over observed | inferred = strong but indirect | UNVERIFIED = not measured this pass"
parity_claim: false
---

# NATION-SPAWN-IMPL-01 — resolve nation-specific sids for `BATTLE_ARMY` starting units

## 1. Stance and result

This ticket implements the single sim-side gap identified by `reports/NATION_SPAWN_01.md`
(§2 hop 5, §3, §6): `BATTLE_ARMY` starting units were spawned with literal generic
sids at `game.gd:2739` (pre-edit) while trained units already resolved through
`Data.resolve_sid()` at `game.gd:3979`. The change adds **one read-only helper** that
mirrors `train_unit()`'s two-source nation lookup and applies it **only** at that one
army-spawn call. No other call site, no entity-shape change, no state, no data-table
change. Every other behaviour is byte-identical, including the strict `bav` no-op (§5).

**No donor/visual parity claim is made.** Art availability is cited only as on-disk
mesh presence in the source reports; this ticket changes a sim sid, not a mesh.

## 2. Before → after (exact diff)

**Before** (backup `inbox/backup/game.gd.bak-NATIONSPAWN01`, pre-edit `game.gd:2733-2740`):

```gdscript
		for sid in army:
			for k in int(round(float(army[sid]) * scale)):
				var a := TAU * ring / maxf(1.0, float(total))
				spawn(sid, i, c + Vector2(cos(a), sin(a)) * (cr + 3.0 + (ring % 4) * 1.5))
				ring += 1
```

There was no `_spawn_sid` symbol in `game.gd` (grep this pass: only `resolve_sid` at
`:3979` and `:3984`). [observed]

**After** (owned file `variant3d/scripts/game.gd`):

1. New read-only helper after `_nation_name()` (post-edit `game.gd:434-444`, `func` at `:438`):

```gdscript
# Nation-aware sid for BATTLE_ARMY starting units. Mirrors train_unit()'s
# two-source nation lookup (players[].nation, then Data.PLAYER_NATIONS) with
# bounds guards; read-only, no entity-field or state change. Identity when
# Data.resolve_sid has no mapping (e.g. bav has no NATION_UNITS key).
func _spawn_sid(player: int, sid: String) -> String:
	var nat := ""
	if player >= 0 and player < players.size():
		nat = str(players[player].get("nation", ""))
	if nat == "" and player >= 0 and player < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[player])
	return Data.resolve_sid(nat, sid)
```

2. One call-site change at post-edit `game.gd:2751` (pre-edit `:2739`):

```gdscript
					spawn(_spawn_sid(i, sid), i, c + Vector2(cos(a), sin(a)) * (cr + 3.0 + (ring % 4) * 1.5))
```

The `total` loop (`:2745-2746`), ring/angle arithmetic (`:2748-2752`) and `ring += 1`
are unchanged; map layout, `next_id` ordering and RNG draws stay byte-stable. [derived
from the diff in §2; observed as a two-hunk `git diff --no-index` against the backup]

`git diff --no-index inbox/backup/game.gd.bak-NATIONSPAWN01 variant3d/scripts/game.gd`
shows **exactly two hunks**: the helper insertion at `@@ -431,6 +431,18 @@` and the
one-line spawn change at `@@ -2736,7 +2748,7 @@`. No third hunk exists. [observed]

### 2.1 What was deliberately NOT touched

| Site | Pre-edit line | Reason |
|---|---|---|
| `spawn()` signature / entity dict | `:2198-2209` | Renderer already recovers nation from player state (`world3d_entities.gd:653-671`); adding `e["nation"]` would change `serialize()` shape (`:5744-5779`) and weaken the selftest baseline parity print (`selftest.gd:82-96`). |
| `cen` / `peasant` / `tow` / `cannon` literal spawns | `:2710,:2721,:2725,:2727` | No `NATION_UNITS` entry (`data.gd:294-305`) ⇒ resolving is a no-op today; `cen`/`peasant` are depended on by town-hall/builder logic. Smallest blast radius. |
| `train_unit()` nation + captured-nation override | `:3976-3987` | Already resolves; queue stores resolved sid (`:4039,:4048`) and completion reuses it (`:5495`). Re-resolving is unnecessary. Reuses its lookup verbatim instead. |
| `cmd_build` spawn | `:3939` | No nation mapping for its sid; out of scope. |
| Queue completion | `:5495` | Consumes the already-resolved `job.sid`. |
| `data.gd`, `world3d_entities.gd`, tests, config, `app/**` | — | Explicitly outside exclusive ownership; untouched. |

## 3. Backup

`inbox/backup/game.gd.bak-NATIONSPAWN01`, 236,360 bytes — byte-identical in length to
the pre-edit `variant3d/scripts/game.gd` (236,360 B). Created with `Copy-Item -Force`
before any edit. Diffing this backup against the edited file produced exactly the two
hunks in §2. [observed]

## 4. Validation — variant runner only

Runner spool: `variant3d/.godot_queue` (variant, not 2D `app/`). Jobs submitted once
each with fresh unique ids; no re-submit, no `ack`/`reset`/spool mutation, no direct
`godot`. FIFO waits were normal (documented in `RUN_GUIDE.md:101,130`).

| Ticket | id | Command (after `python variant3d\tools\godot_runner.py run --id … --timeout … --`) | Result | Wait / run | Artifacts | SCRIPT ERROR |
|---:|---|---|---|---|---|---|
| 533 | `nationspawn01-smoke` | `--headless --path variant3d --check-only --script res://scripts/game.gd` | **`ok` / exit 0** | 432.19 s wait / 24.81 s run | `variant3d/.godot_queue/results/00000533_nationspawn01-smoke/stdout.txt` (75 B, Godot 4.7.2 banner only); `stderr.txt` **0 B** | **0** (0 bytes of stderr) |

This is a **parse/validation smoke**, not a runtime proof: `--check-only` parses and
validates the script but does not execute `setup()` or the spawn loop
(`CONFIG_PIPELINE.md:310,325`; `AUDIO_SEL_02.md:158`). It proves the edit is
syntactically valid and introduces no parse error; it does not by itself prove the
sid histogram. [observed + derived]

### 4.1 Per-player sid dump probe

PENDING — job `nationspawn01-sid-dump` submitted; result to be recorded here on
completion.

## 5. `bav` no-op proof

`Data.resolve_sid` is `NATION_UNITS.get(nat, {})` → `m.get(sid, sid)` → `return r if
UNITS.has(r) else sid` (`data.gd:1564-1567`). `NATION_UNITS` (`data.gd:294-305`) has
keys `rus/ukr/pol/tur/alg/swe/sco` and **no `bav` key** — verified by reading the full
literal this pass. Therefore for every `BATTLE_ARMY` sid `s`:

`_spawn_sid(1, s) = Data.resolve_sid("bav", s) = s`

because `NATION_UNITS.get("bav", {})` is `{}` and `m.get(s, s) = s`. The pre-change
Bavarian starting-army sid histogram is preserved **exactly**; the change is a strict
no-op for `bav` (and for any nation absent from `NATION_UNITS`, and for every unmapped
generic sid such as `pikeman`, `archer`, `officer`, `cannon`). [observed + derived]

For `rus` (player 0 at default config `config.json:71-72`), `NATION_UNITS.rus`
(`data.gd:295`) maps `serdiuk → strelet` and `cossack → cossackdon`, both present in
`UNITS`, so only those two of the six `BATTLE_ARMY` sids (`data.gd:1561`) resolve;
`pikeman/archer/officer/cannon` remain generic. [observed + derived]

## 6. No-weakening statement

- No assertion, step name, step count or passed-condition in `selftest.gd`/`uitest.gd`
  was edited. No test artifact was touched.
- No `NATION_UNITS`, `UNITS`, `resolve_sid`, config or entity-dict shape was changed.
- No gate was re-run hoping for green; no red result was ack-ed or explained away.
- The known red gate is **unchanged and correctly attributed**: variant selftest is
  28/29 with failed step `build` per `RUN_GUIDE.md:57,109` and `DEFAULTS_VERIFY_01.md`
  as cited there. This ticket did not cause it and did not hide it; it predates the
  edit and belongs to its own owner. [observed, second-hand citation]
- The smoke job is parse-only; it is **not** presented as proof of runtime behaviour
  or of the 29/29 selftest. [observed + derived]

## 7. Open questions

1. The sid-dump probe result is pending; whether the resolved `rus` sids actually
   appear in `game.serialize()` at runtime is **[UNVERIFIED]** until §4.1 is filled.
2. `app/scripts/game.gd` is a separate mirror at different offsets
   (`NATION_SPAWN_01.md:99`, `:1988/:2504/:3775`). This ticket was granted exclusive
   ownership of `variant3d/scripts/game.gd` only; whether the mirror must be patched
   is **[UNVERIFIED]** and out of scope here.
3. Most donor nation-unique units have no port mesh (`NATION_DONOR_01.md` G8/G9
   `:188-189`); a resolved `rus` sid may still render through a bbox proxy or a
   different donor-family mesh. Visual result is **[UNVERIFIED]**; no parity claim.
4. `NATION_DATA_01.md` was not on disk when the plan was written
   (`NATION_SPAWN_01.md:26,146`); any later `NATION_UNITS` addition is compatible with
   this change because the fallback is identity. **[UNVERIFIED]** on its contents.
5. Captured-nation override cannot affect starting spawns (`_spawn_starts()` runs at
   `:426-431` before capture logic at `:3982-3987`) — ordering derived, desirability
   a product question. **[UNVERIFIED]**.

## 8. Summary

One read-only helper (`game.gd:438-444`) mirroring `train_unit()`'s two-source nation
lookup, applied at exactly one call site (`game.gd:2751`), makes `BATTLE_ARMY` starting
sids nation-aware with an inherent identity fallback. `bav` is a strict no-op; `rus`
resolves only `serdiuk→strelet` and `cossack→cossackdon`. Parse smoke `nationspawn01-smoke`
(ticket 533) is `ok`/0 with 0 B stderr. No other repo file was edited. Sid-dump probe
and its honest result are recorded in §4.1.

*End of NATION-SPAWN-IMPL-01.*
