---
id: DEC-ATTACK-WORK-ACTIONS
swarm: TERRAIN-SWARM-2026-11-26
role: READ-ONLY decomp/code-audit — combat + work action mapping decision
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_ATTACK_WORK_ACTIONS.md
status: DELIVERED__READ_ONLY__NO_CODE__NO_GODOT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, INFERRED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; no donor parity claim. No donor GPU A/B frame exists."
scope_guard: "Exactly one repo file written (this report). No source, asset, config, test, or runner state changed. Donor read-only; no donor bytes copied."
donor_note: "No Craft Anything native-AAF pass used (0 passes, pin t_87f0f3c130b0 not needed): all facts below come from repo files."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/VIDEO_ANIM_3d.md (ranks 1 and 4)
  - variant3d/scripts/anim3d.gd (AAF_ACTIONS :71-90, ACTION_ALIAS :94-96)
  - variant3d/assets/models/skin/index.json (66 shipped skins, per-sid actions)
  - variant3d/scripts/world3d_entities.gd:_unit_action (:1635-1657, READ ONLY — another worker owns the file)
  - variant3d/scripts/game.gd (order types + gather/carry sim)
---

# DEC-ATTACK-WORK-ACTIONS — map combat/gather/carry orders to shipped skin actions

## 0. Decision (bounded, smallest safe patch)

Add **two stationary-only branches** to `_unit_action` (owner: `world3d_entities.gd:1635`,
READ ONLY here) gated on **per-sid shipped-skin availability** from `index.json`,
with **explicit fallback to `idle`/`walk`**. No new assets, no new skins, no RNG change,
no donor-parity claim.

- **Combat** (`attack`, `attackground`, stationary): return per-sid best attack
  (`attack0` if shipped, else `attack1`, else `idle`). Reuses the existing
  donor-frame morph path (`anim3d.gd:play/pose_for`).
- **Work** (`gather`, `resow`, stationary): return `idle` — because **no shipped skin
  exports any `work*` action** (see §2). Do NOT invent `workfood`/`workwood` names
  at the call site; `pose_for` would silently substitute a wrong range (§4 trap).
- **Carry-walk** (`gather` order + `carry > 0` + moving, i.e. `_gather_deliver`
  transit to store): return `walk` — because **no shipped skin exports
  `walkfood`/`walkwood`/`walkstone`** (see §2).
- Everything else (dead-first, `build`/`repair`→`construct`, walk-gate `0.15 m/s`,
  `moving` fallback) stays **byte-identical**.

This closes VIDEO-ANIM-3D Rank 1 (firing line has no pose today, §3-S1) as far as is
honestly possible with shipped data, and records Rank 4 (reaping poses) as
**not implementable without a re-export** — the frames were never shipped.

## 1. What the port does today (observed, read-only)

`_unit_action(ed, speed)` (`world3d_entities.gd:1635-1657`) has exactly four outcomes:

1. `dead` → `"death"`.
2. `order.type in {build, repair}` + stationary (measured `speed < 0.15`, or legacy
   `moving==false`) → `"construct"`.
3. measured `speed >= 0` → `"walk"` iff `>= WALK_SPEED_GATE_M_S (0.15)` else `"idle"`.
4. legacy `moving` flag → `"walk"` else `"idle"`.

There is **no combat branch and no work branch** — VIDEO-ANIM-3D §3-S1/S4 and
`CONSTRUCT_SKIN_STATUS` (:206) state this explicitly:
"gather/resow/carry/attack still resolve to idle/walk (no branch)".

## 2. What the shipped skins actually export (observed — `index.json`)

Converter request list (`index.json` top level): only
`idle, idle0, walk, walk0, death, attack0, attack1, construct`.
**`workfood/workwood/workstone`, `walkfood/walkwood/walkstone`, `idlefood/idlewood`,
`reaction`, `prepare0/unprepare0` were never requested and are absent from all 66 skins.**
Counted via repo read (no donor pass): 66 entries, 0 with any `work*`/`*food`/`*wood`/
`*stone` key (other than none). So VIDEO-ANIM-3D Rank 4's premise
("frames already exported for peasant sids") is **out of date relative to the shipped
index** — Rank 4 cannot be wired until `convert_skins.py` is re-run with work actions.

Per-sid attack availability (observed, full enumeration):

- `attack0`-only (majority: peasants `pearus/peaukr/peapol/peaaus/peaeng/peaspa/peatur/
  peasco/peasant`, pikemen, `roundshier/cossack/dragoon/officer/strelet/...`, artillery
  `cannon/howitzer/mortar/multicannon/framegun`, `archer/tatar` have both — see next).
- **Both `attack0`+`attack1`**: `musketeer18bav, archer, cannon, grenadier, musk18,
  tatar, archersco` (7 sids).
- **`attack1`-only (no `attack0`)**: `musketeer, serdiuk, jannisary, pandur, chasseur,
  highlander, musketeersco` (7 sids). A naive "always return attack0" would give these
  sids a **wrong-range pose** (see §4 trap) — hence the per-sid gate.
- **Neither attack**: `drummer, drummer18, bagpiper` (only `death/idle/walk`).
- `walk0` present only on a subset (pikeman/musketeer/grenadier families, `serdiuk`,
  `archer`, …); every skin has plain `walk`, so the walker must keep returning `"walk"`
  and never `"walk0"`.
- Artillery/guns (`cannon/howitzer/mortar/multicannon/framegun`) have **no `death`**
  entry; the dead-first branch is still kept unchanged (fallback behaviour §4).

Donor reference ranges (for the owner only, not shipped per-sid):
`anim3d.gd:71-90` (`AAF_ACTIONS`, from `peaukr.aaf:3-20`) defines `attack0 [237,254]`,
`workfood [278,299]`, `workwood [237,254]`, `workstone [217,234]`, `walkfood [257,276]`,
`walkwood [22,41]`, `walkstone [43,62]` — but `peaukr.aaf` itself has **no `attack1`**;
`attack1` ranges exist only inside each buyer's own AAF/skin. So there is **no donor
ground for "attack0 = melee vs attack1 = volley"** (or vice versa). The choice below
is a presentation preference (`attack0` first), explicitly labelled PORT APPROXIMATION.

Alias (already shipped): `ACTION_ALIAS {"attack": "attack0"}` (`anim3d.gd:94-96`,
because the 2D sim emits `"attack"` at `world.gd:475-476`). The patch below does not
rely on it for `attack1`-only sids — it selects the literal shipped name.

## 3. Sim order types that matter (observed — `game.gd`)

Producer sites: `game.gd:3596 attack, :3603 attackmove, :3626/:3633 gather,
:3647 resow, :3653 build, :3683 guard, :3700 patrol, :3706 attackground,
:3579 move, :4949 repair`, plus `none`.

Tick semantics relevant to the visual gate:

- `attack` (:5347-5409): moves into range (`moving=true` + `_step_move`), holds
  (`moving=false`) when in `[w.min, w.max]` and fires via `_fire` (cooldown-gated).
  **Stationary + `moving==false` ⇔ firing stance.** Mortar-vs-nonbuilding holds fire
  with order kept — still stationary, still attack pose.
- `attackground` (:5492-5510): same shape — travel until in range, then stationary
  `deploy_t`/`cooldown` loop. Stationary ⇔ firing.
- `attackmove/patrol/guard/move` convert to `attack` when contact is acquired
  (:5563, :5426, :5445) or are pure movement — they keep the existing walk/idle gate.
  Do NOT attach attack poses to them (unit is displacing, not firing).
- `gather` → `_tick_gather` (:5895-5976): travel to slot (`moving=true`), then
  stationary `hit_t` accumulation, `carry+=1/carry_type=res` per hit, `post_event chop`.
  Full (`carry >= GATHER[res].hits`) or node-empty → `_gather_deliver` (:5978-6032):
  order **stays `gather`** while walking to `nearest_drop` store (`moving=true`,
  `delivering=true`), then deposit, `carry=0`, resume/redirect. So:
  - stationary + `gather/resow` ⇔ working the node (would-be work pose);
  - moving + `gather` + `carry>0` ⇔ carry-walk (would-be `walkfood/walkwood`).
- `resow` (:5454-5473): travel, then stationary 2 s `hit_t`, then flips to
  `gather food`. Same stationary gate as gather.
- `build/repair` (:5474-5546): travel to slot, then stationary `hit_t` work loop.
  Already mapped to `construct`; untouched.

## 4. Why the per-sid gate is load-bearing (trap for the owner)

`anim3d._action_range_for` (:990-1013): a compact shipped skin serves its **own** range
when `actions.has(action)`; otherwise it **falls back to the peaukr table** when the
name exists there. Consequence: requesting `attack0` for an `attack1`-only sid
(`musketeer`, `serdiuk`, …) does NOT return `{ok:false}` — it returns peaukr's
`attack0 [237,254]` range and `_nearest_exported_frame` then snaps to whatever that
sid did export. The pose would be silently wrong, not visibly missing. Same for
requesting `workfood`/`walkfood` for any sid today: falls back to peaukr's work ranges
and samples a nearest exported frame — a plausible-looking but **semantically false**
pose. Hence: **never request an action the sid's own `actions` map does not list;
check `has_skin`/`skin_info` (or the `index.json` table in §2) first, else fall back
to `idle`/`walk`.**

No native-AAF Craft Anything pass was needed for this decision (0 passes against pin
`t_87f0f3c130b0`); per-sid availability is fully determined by the shipped `index.json`
plus the fallback rule quoted above. If native AAF data is ever pulled, the only open
question it could answer is the `attack0`-vs-`attack1` semantic (volley vs melee),
which is currently UNVERIFIED and intentionally not decided here.

## 5. Smallest safe patch — pseudocode for the owning worker (do NOT apply here)

Constraints: dead-first unchanged; `build`/`repair` block unchanged; walk gate
`0.15 m/s` unchanged; no new assets; no RNG; no change to `anim3d.gd`
(the `attack→attack0` alias already covers the generic string).

```gdscript
# Insert AFTER the existing build/repair block, BEFORE the speed walk/idle gate.
# od / otype already exist above; sid = str(ed.get("sid", "")).
# stationary mirrors the construct branch: measured speed wins, else legacy moving flag.
var stationary := true
if speed >= 0.0:
    stationary = speed < WALK_SPEED_GATE_M_S
else:
    stationary = not bool(ed.get("moving", false))
if od is Dictionary and stationary:
    var otype2 := str((od as Dictionary).get("type", ""))
    # --- combat: firing stance only (in-range, not displacing) ---
    if otype2 == "attack" or otype2 == "attackground":
        return _best_attack_action(sid)  # attack0 > attack1 > idle (own helper below)
    # --- work: node contact (no work* frames shipped -> hold idle, never walk-cycle) ---
    if otype2 == "gather" or otype2 == "resow":
        return "idle"
# carry-walk needs NO branch: order is still gather + moving, so the existing
# walk/idle gate below already yields "walk" (correct: no walkfood/walkwood shipped).
# ... existing tail unchanged:
# if speed >= 0.0: return "walk" if speed >= GATE else "idle"
# if moving: return "walk"; return "idle"

# New tiny helper beside _unit_action (same file, owned by the same worker):
func _best_attack_action(sid: String) -> String:
    # Gate on the sid's OWN shipped actions (anim3d skin_info / index.json §2).
    # has_skin(sid) false, or an unlisted name, must never be requested (§4 trap).
    if not anim3d.has_skin(sid):
        return "idle"
    var names: Array = anim3d.skin_info(sid).get("actions", [])
    if "attack0" in names:
        return "attack0"
    if "attack1" in names:
        return "attack1"
    return "idle"  # drummer/bagpiper/piper-likes: hold formation idle, not a wrong range
```

Behaviour table (stationary unless noted):

| Order (+ sim state) | Returns | Ground |
|---|---|---|
| `attack` / `attackground`, stationary | `attack0` if shipped, else `attack1`, else `idle` | own-skin gate §2; alias :94 |
| `attack` while closing range (moving) | `walk` (existing gate) | displacing, not firing |
| `attackmove` / `patrol` / `guard` / `move` | unchanged walk/idle | movement orders; sim converts to `attack` on contact |
| `gather` / `resow`, stationary | `idle` | no `work*` shipped in any of 66 skins |
| `gather` + `carry>0`, moving (delivery) | `walk` (existing gate) | no `walkfood/walkwood` shipped |
| `build` / `repair` | `construct` (existing) | unchanged |
| `dead` | `death` (existing, first) | unchanged (artillery has no own death: fallback, UNVERIFIED) |

Explicit non-goals: no `attack1`-vs-`attack0` semantic (volley/melee) — UNVERIFIED;
no `walk0` selection (keep `"walk"`); no `prepare0/unprepare0/reaction/idlefood`
wiring (not requested by gameplay); no timing/loop change (all AAF kinds are `morph`,
loop flag UNVERIFIED per `anim3d.gd:220`).

## 6. Verification for the owner (suggested, not performed here)

1. Static: `grep attack0|attack1 world3d_entities.gd` shows the only new strings inside
   `_unit_action` + `_best_attack_action`; no other file touched.
2. Runtime probe (headless): for each sid in §2, call `_unit_action` with
   `{sid, order:{type:attack}, moving:false}` + `speed=0.0` and assert the §2 table
   (`musketeer→attack1`, `peaukr→attack0`, `drummer→idle`); `gather`+stationary→`idle`;
   `gather`+`carry=5`+`speed=2.0`→`walk`; `build` stationary still `construct`.
3. Visual: UNVERIFIED by construction — flat-root morph (`BLOCKED_RIG`), no A/B frame;
   label stays PORT APPROXIMATION.

## 7. Open / unresolved (no parity claim)

- `attack0`-vs-`attack1` meaning per weapon class: UNVERIFIED from repo data
  (peaukr AAF has no `attack1`). A future native-AAF pass (pin `t_87f0f3c130b0`,
  ≤3 passes) could compare per-weapon AAF ranges, but is not required for this patch.
- Rank 4 (`workfood/workwood/workstone`, `walkfood/walkwood`) needs a `convert_skins.py`
  re-export adding those actions to `actions_requested`, then the `gather/resow`
  branch above can select per-`res` (`food→workfood`, `wood→workwood`, `stone→
  workstone`; delivery `carry_type` → `walkfood/walkwood`, `stone` → `walk`), still
  gated per-sid with idle/walk fallback. Until then, `idle`/`walk` is the honest pose.
- No statement is made about donor motion fidelity; all new poses reuse the existing
  UNVERIFIED flat-root morph path.

*End of DEC-ATTACK-WORK-ACTIONS (read-only; owning worker applies §5 or rejects with reasons).*
