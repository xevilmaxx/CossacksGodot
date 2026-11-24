---
id: PLAY2-03
owner: PLAY2-03
date: 2026-11-24
mode: "READ-ONLY audit — current source + persisted runner artifacts only; no Godot launch, no source/git/asset edit"
charter: "PLAYABILITY2_CHARTER.md:12-19, :24 — one report, path:line evidence, separate root cause from fix, no visual-parity claim"
deliverable: "docs/coord_swarm_2026-11-24/reports/PLAY2_03_animations.md"
status: "VERDICT DELIVERED — 3D peasant morph DATA is live and donor-grounded; the ACTION SET the renderer requests is a 3-state stub, so most peasant work is animated as idle/walk"
visual_parity: "NONE CLAIMED — flat-root PORT APPROXIMATION — NOT DONOR PARITY; visual UNVERIFIED"
---

# PLAY2-03 — are peasant animations actually correct in the current 3D source?

## 0. Honest verdict and the top 3 gaps

**Verdict: data path ON, action coverage OFF.** The 3D runtime really does skin a
`peasant` from donor `peaukr.oss` frames and rebuild rendered mesh vertices — that
is PROVEN by current source and persisted runner stdout. But the renderer asks for
only **three** actions (`idle`, `walk`, `death`), and `death` is unreachable in
normal play. A peasant that gathers, builds, repairs, resows, carries a load or
attacks therefore visibly plays **idle or walk** in 3D, while the 2D game selects
one of **14** clip classes for the same unit. Visual fidelity of even the three
working clips remains UNVERIFIED; no rendered A/B exists.

Top 3 gaps (ranked):

1. **Renderer action policy is a 3-state stub** — `world3d_entities.gd:739-744`
   vs `app/scripts/world.gd:470-499`. No attack / gather / build / carry action is
   ever requested by the 3D renderer. This is the user-visible defect.
2. **Shipped skins do not contain the work/build/carry clips** —
   `convert_skins.py:69-73` requests only 7 actions; `peasant.json:1` has 5
   (`idle, idle0, walk, death, attack0`). Fixing gap 1 alone would silently fall
   back to the hardcoded peaukr table (`anim3d.gd:79-86`) and snap to unrelated
   exported frames — wrong motion, not donor-grounded.
3. **No death visual in 3D** — dead sim units are removed before `sync()`
   (`world3d.gd:337, :684-686`), the sim puts them in `game.corpses`
   (`app/scripts/game.gd:4142-4160`), and no `world3d*` file reads corpses. 2D
   plays the death sheet from corpses (`app/scripts/world.gd:3387-3426`).

Explicit answer to the two framed worries: the V7-79 memo **does not** freeze
units that share a frame (§1.1), and frame selection is **derived from donor AAF
range + global sim time**, not a hardcoded counter (§1.2).

---

## 1. Scope item 1 — `world3d_entities.gd`: what `sync()` really does

| Claim | Current evidence | Verdict |
|---|---|---|
| anim3d is really composed and bound | `world3d.gd:112,134`; `:214-218` `add_child(inst)`; `:603` `_instantiate(ANIM_SCRIPT)`; `:645` `anim.bind(game, entities)` | CONFIRMED — `anim` and `entities` are siblings, so `_find_anim()` (`:716-731`) finds the anim module by its `pose_for`/`has_skin` methods |
| `pose_for()` is called per unit per sync | `:1231` `anim.call("pose_for", ed, action, _anim_t)` is **inside** a memo guard (`:1227-1234`) | **NO — NOT per unit.** One sample per distinct `(sid, action)` per `sync()`. Telemetry `stats["donor_morph_pose_samples"]` (`:1311`) counts actual calls |
| Mesh vertices are rebuilt for every visible unit | `_morph_mesh()` `:802-891`; cache key `sid|action|f<frame>` at `:804-806` — returns cached mesh on hit | **NO — NOT per unit.** Rebuild once per distinct `(sid, action, frame)`; later units reuse the cached `ArrayMesh` via batch key at `:1248-1257` |
| Units are gated by skin availability | `:1225-1226` `anim.has_method("pose_for") and bool(anim.call("has_skin", sid))` | CONFIRMED — unskinned sids keep the static bind batch (`static_units` at `:1263`) |
| Hidden/dead units sampled? | Pass 1 iterates all `_slot` keys (`:1210`), not filtered by `_is_hidden()`; `_xf()` scales hidden units (`:1056`) | Sampled but invisible; no death action in practice (§3, gap 3) |
| Frame source | `anim3d.gd:582-588` `_frame_at(first,last,t)` = `first + floor(fposmod(t*DONOR_FPS, span))`, `DONOR_FPS=30` (`:59`); `t` is `_anim_t` accumulated by `maxf(dt,0)` at `world3d_entities.gd:1190`; range from `_action_range_for()` (`anim3d.gd:918-934`) | **Donor AAF action range + donor-time clock, NOT a hardcoded counter.** `first/last` are inclusive donor AAF bounds; no frame index is invented in this file |
| V7-79 memo can freeze units sharing a frame | `:1198-1207` comment + `pose_memo`; `:1227` `memo_key := sid + "|" + action`; memo is a **local** dict recreated every `sync()` | **NO freeze today.** Within one pass `_anim_t` is constant and `pose_for`'s frame depends only on `(sid, action, t)`, so `(sid,action)` is an exact partition of `(sid,action,frame)`. Cached pose carries its own resolved `frame` (`:1231, :1240, :1251`). The `_morph_meshes` cache is keyed by the resolved frame and is deterministic. V7-79 report `V779_pose_memo.md:77-83, :157-162` records the same scope caveat. **Latent trap:** any future fix that makes frame depend on per-unit state must add frame/phase to `memo_key`, or units WILL be frozen to the first unit's frame |

**Measured, not inferred** (persisted artifacts, not deleted probe reports):

- `variant3d/.godot_queue/results/00000181_v778-auto-skin-probe3/stdout.txt`:
  `auto_loaded=55 bytes=3712594 error=''`, `has_skin('peasant') without manual
  registration`, `donor_morph_units=1`, `frames [64] -> [74]`,
  `733/733 verts changed`, walk `[1] -> [9]` `733/733 changed`,
  `pose_source=donor_flat_root_morph`.
- `variant3d/.godot_queue/results/00000200_v779-probe-after2/stdout.txt`:
  200 units → `morph_units=200 samples=6 morph_delta=118.295390 frames=1->16`,
  batches/cached both 36. This directly proves the memo does not stop morphing.

## 2. Scope item 2 — `anim3d.gd`: shipped skins and available actions

| Question | Evidence | Answer |
|---|---|---|
| Are 55 skins auto-registered? | `anim3d.gd:110-124` consts/state; `:742-765` `_ensure_shipped_skins()` (lazy, once, strict index load); called from `bind()` `:136`, `has_skin()` `:314`, `pose_for()` `:490`; `:771-888` `_load_shipped_skin()` registers under real roster sid | **YES.** Probe artifact ticket 181: `auto_loaded=55`, error empty, no `register_skin()` call |
| Where does the data come from? | `anim3d.gd:112-114` `SKIN_INDEX_PATH/ASSET_DIR`; `:747-765` reads `index.json` then each `<sid>.json`; no donor path at runtime | Offline donor-derived JSON only (`convert_skins.py`), 3.75 MB |
| What actions exist in the hardcoded table? | `anim3d.gd:71-90` — 18 donor peaukr AAF names: `idle, idle0, walk, death, attack0, workfood, workwood, workstone, idlefood, idlewood, idlestone, walkfood, walkwood, walkstone, construct, reaction, prepare0, unprepare0` | Broad donor table present in source |
| Alias for the 2D "attack" name | `anim3d.gd:92-96` `ACTION_ALIAS = {"attack": "attack0"}` | Correct alias exists but is **never exercised** by the 3D renderer |
| What actions are actually in the shipped per-sid assets? | `variant3d/assets/models/skin/index.json:1` `actions_requested = [idle,idle0,walk,walk0,death,attack0,attack1]`, `count=55`; `variant3d/assets/models/skin/peasant.json:1` `actions` = `idle, idle0, walk, death, attack0`; `frames` = 24 exact donor indices | Only 7 requested / 5 present for peasant. **No gather, build, carry or work clip is shipped** |
| Peasant donor grounding | `peasant.json:1` `path = C:\Games\Cossacks 3\data\actors\units\peaukr.oss`, `aaf_path = data/animations/aaf/peaukr.aaf`, `k=483 fps=30 bones=20 v=577`; `k` and `v` independently confirmed in artifact ticket 181 | YES, donor-specific, not invented |
| Are 2D peasant action names used? | Only `pose_for` caller is `world3d_entities.gd:1231`, with `action` from `_unit_action()` `:739-744` (3 names). `world3d.gd:736-739` `play_anim` is a public seam with **zero callers** (repo-wide grep) | **NO.** Every unit animates with one of 3 generic actions; `attack0` alias and all work/construct/carry names are dead in normal play |
| Missing action fallback | `_action_range_for()` `anim3d.gd:918-934`: compact skin action miss → `AAF_ACTIONS` peaukr fallback → `_nearest_exported_frame()` `:907-912` snaps to nearest of 24 shipped frames | Silent wrong-content fallback; e.g. a requested `construct` (AAF 186-198, `:86`) snaps to 149 (death) or 237 (attack) because no frames were exported in that range |

## 3. Scope item 3 — 2D vs 3D action resolution for peasants

`app/scripts/data.gd` contains no action selection: it only loads the extra sheet
index (`app/scripts/data.gd:259-264`); nation-first key resolution is
`app/scripts/world.gd:457-468`. The real comparator is
`app/scripts/world.gd:470-499`.

| 2D action (world.gd:line) | 2D trigger | 3D equivalent | 3D verdict |
|---|---|---|---|
| `death` `:471-472` | `death_t >= 0` | `_unit_action` checks `dead` bool `:740` | **WRONG/unreachable** — sim sets `dead=true` and removes the unit to `corpses` (`app/scripts/game.gd:4142-4160`); `world3d.gd:337` filters dead before `sync()`; no 3D corpse consumer |
| `attack` `:475-476` | `order.type=="attack"` and `fire_t` within 0.9 s | none | **MISSING** — alias `attack→attack0` exists but is never requested |
| `workwood` `:481-486` | `order.type=="gather"`, `res=="wood"` | none | **MISSING** |
| `workfood` `:483, :487-488` | gather food / `order.type=="resow"` | none | **MISSING** |
| `workstone` `:485` | gather stone | none | **MISSING** |
| `construct` `:489-490` | `order.type=="build"` or `"repair"` | none | **MISSING** |
| `idlewood/idlefood/idlestone` `:491-493` | `carry>0` and `carry_type` | none | **MISSING** |
| `walkwood/walkfood/walkstone` `:494-497` | `moving` + `carry_type` | none | **MISSING** |
| `walk` `:498` | moving | `moving` → `walk` `:742-743` | OK (mapping) |
| `idle` `:499` | else | else → `idle` `:744` | OK (mapping) |

2D sheet coverage for `peasant`: 14 actions at
`app/assets/models/anim/land_units/index.json:2-304` (walk `:5`, idle `:28`,
attack `:51`, workwood `:74`, workfood `:97`, workstone `:120`, construct `:143`,
walkwood `:166`, walkfood `:189`, walkstone `:212`, idlewood `:235`, idlefood
`:258`, idlestone `:281`, death `:304`). 3D renderer coverage: 3, of which 1 is
unreachable. **11 of 14 clip classes are never requested in 3D.**

Additional temporal mismatch: 2D phases each unit by a per-entity `phase`
(`app/scripts/world.gd:568-576`), while 3D uses one global `_anim_t`
(`world3d_entities.gd:1190`) so every unit of the same sid/action is frame-locked
(documented as a port choice in `V774_consume_poses.md:183-185`). A `fire_t`- or
`death_t`-aligned one-shot would also need its own start time; `_frame_at()`
(`anim3d.gd:582-588`) only loops from the global clock.

## 4. Scope item 4 — converter coverage, runtime activation, and proof status

**PROVEN (data motion / wiring), with current evidence:**

- Converter covers `peasant`: `variant3d/tools/convert_skins.py:187-268` reads the
  sid's own `.oss` and `.aaf`; `variant3d/assets/models/skin/index.json:1` has 55
  entries, 0 failed, 7 `.osm` hull skips; `peasant.json:1` donor path/header above.
  `convert_skins.py:140-149` `sample_frames` reproduces donor-order 6-frame
  decimation; `:152-175` qmat+skin copied from `bake_sprites.py`.
- Visual morph is active by current code path: `world3d.gd:603 → :645` →
  `anim3d.gd:133-136` → `:742-765` auto-load → `world3d_entities.gd:1185-1262`
  Pass 1 `pose_for` + `_morph_mesh` → `:1248-1257` batch migration. Artifacts
  ticket 181 and 200 (quoted in §1) prove real vert changes with no manual
  registration and under the V7-79 memo.
- `variant3d/selftest.json` is `passed:true`, 29/29, but its `steps` are sim/2D
  oriented (`move, act, fight, build, ...`, no `donor_morph` key). **Selftest green
  does not prove 3D morph in a real match** — it only proves parse/no-crash.

**UNVERIFIED (visual correctness), unchanged by any measurement above:**

- Flat-root skin; donor bone parents unreadable — `anim3d.gd:66` `BLOCKED_RIG`,
  though `DEEPDEC_06_models_anim.md:18-34, :162-211` argues the stored tracks are
  absolute bind deltas, so deformation data is equivalent. No rendered A/B.
- No interpolation between the 6 exported frames/action (`anim3d.gd:893-912`
  nearest-frame snap), so motion is stepped, not smooth.
- Normals generated from morphed faces (`world3d_entities.gd:862-879`), tangents
  unset; Godot UV V-flip at `:851`; donor→Godot quaternion convention uncited.
- Attached hand tools are separate donor meshes, unskinned (`V778_ship_skins.md:229`).
- One-shot `death` would loop via `fposmod` (`anim3d.gd:582-588`), but is
  currently unreachable anyway.
- All provenance labels intentionally retained: `anim3d.gd:63` `PORT_LABEL`,
  `:524` `visual="UNVERIFIED"`; `world3d_entities.gd:124, :889` same.

No screenshot, donor render, or frame A/B was produced by this audit (READ-ONLY,
no Godot launch per charter).

---

## 5. Ranked root causes (not fixes)

**RC1 — 3D action map is a 3-state PORT stub.**
`world3d_entities.gd:739-744`. This is the direct cause of "peasant animations
look wrong" while gathering/building/carrying/attacking. Data for richer actions
exists in `anim3d.gd:71-90` and in the 2D index; the renderer simply never asks.

**RC2 — Converter action subset omits the work/build/carry clips.**
`convert_skins.py:69-73` + `index.json:1` + `peasant.json:1`. It blocks RC1 from
being fixed correctly: a request for an unshipped action falls back to peaukr
ranges (`anim3d.gd:918-934`) and snaps to whichever of 24 frames is nearest,
which can be a death or attack pose. The exporter's own comment
(`convert_skins.py:69-71`) froze the 2D renderer's old 3-action assumption.

**RC3 — No 3D consumer for `game.corpses`, so `death` never renders.**
`app/scripts/game.gd:4142-4160`; `world3d.gd:337, :684-686`; no `corpse` string
in any `variant3d/scripts/world3d*.gd`. The death clip is shipped and skinnable
but dead code in play.

**RC4 (contributing, not proven defect) — global clock + frame cache key.**
`world3d_entities.gd:1190, :1227-1234`; `anim3d.gd:582-588`. Lockstep motion and
non-aligned one-shots are documented port choices (`V774 §7 Q3`, `V778 §6 Q7`);
the `(sid,action)` memo is exact today but becomes a correctness bug the moment
RC1/RC3 introduce per-unit timing.

---

## 6. Smallest donor-grounded fix plan — DO NOT IMPLEMENT

Ordering: **A+B must land together** (A alone yields wrong fallback motion).
Ownership names are the historical owners of each file, to be re-assigned by the
synthesizer; this agent owns no source file.

| Wave | Smallest change | File ownership | Acceptance probe (runner-only, headless) |
|---|---|---|---|
| **A — action map** | Replace `_unit_action()` `world3d_entities.gd:739-744` with a donor-name mapping mirroring `app/scripts/world.gd:470-499` using fields already on the live sim dict (`death_t`/`dead`, `order.type`, `res`, `fire_t`, `carry`, `carry_type`, `moving`). Emit only names from `anim3d.gd:71-90` + `ACTION_ALIAS` `:94-96`: `death`, `attack0`, `workfood/workwood/workstone`, `construct`, `idle*/walk*<res>`, `walk`, `idle`. Change nothing else; keep the memo, batches, labels, tints | owner of `world3d_entities.gd` (V7-74/V7-79 lane) | Add one peasant with `order={type:"gather",res:"wood"}`, `moving=false`, `carry=0`; assert a MORPH batch node exists with meta `donor_action=="workwood"` and `pose_source=donor_flat_root_morph`; repeat `build→construct`, `attack+fire_t→attack0`, `carry>0→idlewood`, `moving+carry→walkwood`. Assert parse ok, selftest 29/29. Do **not** assert visual parity |
| **B — data coverage** | Extend `DEFAULT_ACTIONS` `convert_skins.py:69-73` with the 12 work/carry/construct names present in `anim3d.gd:77-86`, re-run the existing read-only converter with the same `--frames-per-action 6`; regenerate `<sid>.json` + `index.json` (no invented frames, no donor bytes in repo) | owner of `convert_skins.py` + `assets/models/skin/**` (V7-78 lane) | `index.json.actions_requested` contains all names; `peasant.json.actions` has `workwood/workfood/workstone/construct/idle*/walk*`; `pose_for("peasant","workwood",t)` returns `donor` citing `peaukr.aaf:9`, `frame` ∈ its own exported `frames`, `pose_source=donor_flat_root_morph`, verts non-empty and ≠ idle verts. No `.png`/sprite sheet/RNG |
| **C — death visual** | Consume `game.corpses` (`app/scripts/game.gd:4160`) as short-lived death-action unit instances with `death_t`, mirroring `app/scripts/world.gd:3387-3426`; or stop filtering dead units until the death clip completes. Keep `ANIM_STATUS`/`visual=UNVERIFIED` | owners of `world3d.gd` + `world3d_entities.gd` (V7-62/V7-74 lane); `anim3d.gd` unchanged | Kill one peasant in a live `C3Game`; within the same runner assert a batch with meta `donor_action=="death"` appears, advances frames from `death_t`, and disappears at `Data.CORPSE_LIFE`; assert no dead unit ever renders `walk`/`idle` |
| **D — memo guard (must accompany A/C if timing becomes per-unit)** | At `world3d_entities.gd:1227`, include the resolved frame or a per-unit phase in `memo_key` (V7-79 Q1 `V779_pose_memo.md:157-162`); otherwise two units of the same sid/action with different start times are frozen to the first unit's frame | owner of `world3d_entities.gd` | Spawn two same-sid units with different action start times; assert two distinct `pose["frame"]` values and two distinct morph batches; assert `donor_morph_pose_samples` rises accordingly |

Explicit non-goals for these waves: no visual-parity claim, no donor render A/B,
no bone-parent hunt (`DEEPDEC_06 §3/§7`), no 2D bake or sprite sheet in 3D.

---

## 7. UNVERIFIED list (carried forward, unchanged by this audit)

1. **Visual correctness of every 3D clip** — no screenshot / donor A/B; all
   `visual=UNVERIFIED`, `PORT APPROXIMATION — NOT DONOR PARITY`
   (`anim3d.gd:63, :524`; `world3d_entities.gd:124, :889`).
2. **Smoothness** — 6 exported donor frames/action, nearest-frame snap, no
   interpolation (`anim3d.gd:893-912`).
3. **Quaternion convention / normals / UVs / tangents** — donor→Godot mapping
   uncited; normals generated at `world3d_entities.gd:862-879`.
4. **Attached peasant tools** — unskinned, separate donor `.oss`
   (`V778_ship_skins.md:229`).
5. **One-shot loop policy** — `death`/`attack` would loop via `fposmod`
   (`anim3d.gd:582-588`); no AAF loop flag.
6. **Per-unit phase** — global `_anim_t` means lockstep; 2D uses per-unit phase
   (`app/scripts/world.gd:571-576`); 3D parity UNVERIFIED.
7. **Other sids** — only `peasant` was measured in the persisted probes; V774
   §7 Q5 warns multi-surface / GLB-only sids may take the static fallback.
8. **Real-match activation** — selftest has no 3D morph step; activation is
   proven by code path + deleted-probe stdout artifacts (tickets 181/200), not by
   a current reproducible end-to-end test in the tree.

---

*PLAY2-03, read-only. No source, asset, config, test or git change; no Godot
launch. Every claim cites current `path:line` or a persisted runner artifact.
Root causes are separated from the proposed fix; no visual parity is claimed.*
