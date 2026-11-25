---
id: F2-04
ticket: "F2-04 — mine magnetic-snap fix proposal: ghost/placement snaps to the deposit centre"
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: PROPOSAL_ONLY__NO_CODE_EDIT__NO_RUNNER__NO_PARITY_CLAIM
owner: "F2-04 (read-only proposal subagent)"
output: "docs/terrain_swarm_2026-11-25/reports/F2_04_mine_snap.md"
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md"
wave_charter: "docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md#wave-f2"
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave G/F2: lines 126-143)
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/B05_selection_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B06_ghost_impl.md
  - variant3d/scripts/input_controller.gd
  - variant3d/scripts/world3d.gd
  - variant3d/scripts/world3d_fx.gd
  - variant3d/scripts/game.gd
  - variant3d/scripts/world.gd
  - variant3d/scripts/hud.gd
  - variant3d/tests/t_mine_build.gd
  - variant3d/tests/unified_mine_test.gd
  - variant3d/tests/t_ghost_final_stage.gd
f2_02_status: "NOT LANDED at write time — no F2_02*.md in reports/; only WAVE_G_CHARTER.md:135 references it. Donor deposit footprint/snap truth is therefore still pending. This proposal makes no donor-parity claim."
labels: [OBSERVED, DERIVED, PORT_APPROXIMATION, UNVERIFIED]
proposed_owner_files:
  - variant3d/scripts/game.gd
  - variant3d/scripts/world3d.gd
explicitly_untouched:
  - variant3d/scripts/input_controller.gd  # B05 selection quad
  - variant3d/scripts/world3d_fx.gd        # B06 finished-stage ghost mesh
  - variant3d/scripts/world.gd             # 2D ghost — follow-up only
  - variant3d/scripts/hud.gd
  - all tests, fixtures, config, assets
---

# F2-04 — Mine magnetic snap: proposal only

## 0. Guardrails honoured

**OBSERVED** — no Godot process, no runner job, no capture, no test edit and no
source-file edit were made by this agent. `git status --short` at write time shows
only the pre-existing concurrent swarm edits (B01-B06/G02 etc.); this report is
the sole new artifact from F2-04.

WAVE_G_CHARTER.md:140-141: *"All read-only/proposal only while G04 runs gates.
COORD grants exclusive file owners after G04 finishes. No runner jobs, no
donor-parity claims."* This report is a ready-to-apply diff, not an applied fix.
Line numbers are **current-tree** at 2026-11-25 (post-B03/B05/B06); COORD must
re-confirm the hunk context before applying because sibling agents still edit the
tree.

---

## 1. Current build-placement path (end-to-end trace)

All items below are **OBSERVED** code reads; the conclusion in §2 is **DERIVED**.

| # | Stage | Exact site | What it does with the cursor point |
|---|---|---|---|
| 1 | Build option armed | `input_controller.gd:1345-1357` (hotkey), `hud.gd:1249-1274` (menu) | `hud.build_ghost_sid = "mine"`; the single generic Mine button is kept. No world point used. |
| 2 | Per-frame ghost handoff | `input_controller.gd:1507-1515` (`_process`) | `world.set_build_ghost_pos(_screen_to_world(get_viewport().get_mouse_position()))` — **raw** SIM ground point from `picking3d.ground_point()`, gated to `render_mode == "3d"`. This is B05's FIX-GHOST handoff; selection-quad code at `:1494-1535` is unrelated. |
| 3 | Ghost point storage | `world3d.gd:784-786` `set_build_ghost_pos()` | Stores the raw point in `_ghost_pos`, sets `_ghost_pos_override = true`. |
| 4 | Ghost point read + sid resolve + verdict | `world3d.gd:463-498` `_sync_build_ghost()` | `wp = _ghost_world_pos()` (raw, `:475`); `in_bounds(wp)` (`:480-483`); `sid = resolve_mine_sid(sid, wp)` (`:485-486`); unknown-sid guard (`:488-490`); `chk = can_place(0, sid, wp)` (`:492-495`); `fx.draw_ghost(sid, wp, ok)` (`:498`) — **raw** point all the way through. |
| 5 | Mesh / transform | `world3d_fx.gd:580-604` `draw_ghost()` | `_ghost_root.position = world_pos(pos)` at `:595`; `_ghost_swap_building_mesh(s)` at `:603` resolves the B06 finished base mesh (`:640-694`, node `GhostBuildingFinished` at `:922`). B06 never touches `pos`. |
| 6 | Click | `input_controller.gd:821-849` | `pos := pw` (raw); `hud.build_gate(sid, pos)` is a **cost/peasant/research** gate only (`hud.gd:1224-1241`) — it does not use `pos` for legality; `can_place` echo at `:841-844` is hint-only and does not block; `game.place_building(0, sid, pos, true, sel_peasants)` at `:845` gets the raw point. |
| 7 | Mine creation | `game.gd:4092-4111` `place_building()` | `sid = resolve_mine_sid(sid, pos)` (`:4094`); `can_place(player, sid, pos)` on the **raw** point (`:4102`); then `:4107-4111` **already snaps** `pos = n.pos` to the first matching ore deposit with `n.max_hits == 0` and `distance < MINE_SITE_RADIUS`, and only after that spawns the site (`:4135`). |

`can_place()` itself (`game.gd:3986-4058`) for any mine sid checks `in_bounds`,
then the deposit-in-radius test at `:3992-4015` using the resource spatial hash
and `MINE_SITE_RADIUS`, and **returns early with `{ok:true}` at `:4015`** — no
footprint/water/building checks for mines. With no deposit it returns
`"Mines must be built on an ore deposit."` at `:4014`.

Relevant constants (all `game.gd`): `TILE := 2.0` (`:16`),
`MINE_SITE_RADIUS := 4.0` (`:19`), `MINE_MIN_SEP_TILES := 11.0` (`:34`, i.e. ore
centres are kept ~22 m apart by `_ore_spot_clear` at `:2774-2778`),
`RES_GRID_M := 16.0` (`:158`), `_res_grid_ensure()` at `:3040-3055`.

---

## 2. Root cause (DERIVED)

**The site already snaps; the preview does not.** `place_building()`
(`game.gd:4107-4111`) centres the finished mine on the ore deposit, but the 3D
hologram is positioned from the raw cursor point at `world3d.gd:475/498` →
`world3d_fx.gd:595`. With `MINE_SITE_RADIUS = 4.0 m`, the player can see a
green finished-mine hologram up to 4 m away from where the mine actually
appears on click. That is the owner's *"mines when placed on correct spot use
magnetic snap for correct positioning when building the mine on it"* defect:
the snap exists in the sim but is invisible in the preview, so placement looks
unmagnetised.

Secondary consequence: the ghost's green/red verdict is computed at the raw
point (`:493`) rather than at the snapped site, so the colour is not literally
the verdict of the point that gets built.

**Exact insertion point:** `world3d.gd:_sync_build_ghost()`, **between the
unknown-sid guard (`:488-490`) and `var ok := false` (`:491`)**. One insertion
there fixes both the ghost world position and its validity verdict, and also
covers the headless/camera fallback `_ghost_world_pos()` path. It leaves
`input_controller.gd` (B05), `world3d_fx.gd` (B06), `can_place()`, `place_building()`
and every test byte-identical.

---

## 3. Minimal fix design

1. **`game.gd`**: add one read-only helper `snap_mine_pos(sid, pos) -> Vector2`
   immediately after `resolve_mine_sid()` (`:3096`), before `_mine_debug()`
   (`:3098`). It reuses the existing `_res_grid` spatial hash (the same query
   shape as `can_place` at `:3997-4012`) so the per-frame ghost call does not
   add a full `res_nodes` scan. It returns:
   - `pos` unchanged for any non-mine sid;
   - the nearest matching ore-deposit centre for a mine sid when one lies
     within `MINE_SITE_RADIUS` (strict `<`, same as `can_place`/`place_building`);
   - `pos` unchanged when no deposit is in range, so `can_place()` keeps its
     current reject reason and 2D/HUD callers are unaffected.

2. **`world3d.gd`**: call it in `_sync_build_ghost()` right after the resolved
   sid is known and before `can_place()`, guarded by `has_method()` so stub
   games in probes stay safe. `wp` then holds the snapped centre for both the
   verdict and `fx.draw_ghost()`.

**Why not touch the click path:** `place_building()` already snaps at
`game.gd:4107-4111`. Editing `input_controller.gd` would needlessly enter B05's
owned file, and replacing that sim loop would enter tested placement code with
no functional gain on generated maps. The two rules coincide in practice:
deposits of the same ore are separated by ~22 m (`game.gd:34`, `:2774-2778`)
while the snap radius is 4 m, so at most one matching deposit can ever be in
range — the helper's *nearest* and `place_building`'s *first* select the same
node (**DERIVED**; hand-edited maps with overlapping deposits are **UNVERIFIED**).
Consolidating the loop into the helper is listed as an optional follow-up in §8.

---

## 4. Exact unified diff (proposed — NOT applied)

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -3094,6 +3094,38 @@ func resolve_mine_sid(sid: String, pos: Vector2) -> String:
 	# No deposit in range: preview a gold mine; can_place will explain the
 	# problem (the generic reason is shared by all three mine types).
 	return "mine_" + best_type if best_type != "" else "mine_gold"
 
+# F2-04: magnetically snap a mine preview to the ore deposit centre the click
+# will use. place_building() ALREADY snaps the site to the nearest matching
+# deposit (game.gd:4107-4111); this read-only helper applies the same rule to
+# the preview point so the hologram is not left floating beside the mine.
+# Non-mine sids, and mines with no deposit inside MINE_SITE_RADIUS, return pos
+# unchanged, so can_place() keeps its exact current verdict/reason.
+# Donor snap rule is UNVERIFIED (no donor line/capture found); this mirrors the
+# port's own snap = PORT APPROXIMATION, NOT DONOR PARITY.
+func snap_mine_pos(sid: String, pos: Vector2) -> Vector2:
+	if sid != "mine" and not sid.begins_with("mine_"):
+		return pos
+	var want: String = ""
+	if sid != "mine":
+		want = str(Data.BUILDINGS.get(sid, {}).get("mine", ""))
+	_res_grid_ensure()
+	var c0 := Vector2i(int((pos.x - MINE_SITE_RADIUS) / RES_GRID_M), int((pos.y - MINE_SITE_RADIUS) / RES_GRID_M))
+	var c1 := Vector2i(int((pos.x + MINE_SITE_RADIUS) / RES_GRID_M), int((pos.y + MINE_SITE_RADIUS) / RES_GRID_M))
+	var best_d := MINE_SITE_RADIUS
+	var best_pos := pos
+	for cy in range(c0.y, c1.y + 1):
+		for cx in range(c0.x, c1.x + 1):
+			for n in (_res_grid.get(Vector2i(cx, cy), []) as Array):
+				if int(n.get("max_hits", -1)) != 0:
+					continue
+				if want != "" and str(n.get("type", "")) != want:
+					continue
+				var d: float = (n.pos as Vector2).distance_to(pos)
+				if d < best_d:
+					best_d = d
+					best_pos = n.pos as Vector2
+	return best_pos
+
 func _mine_debug(res: String) -> String:
 	var out: Array = []
diff --git a/variant3d/scripts/world3d.gd b/variant3d/scripts/world3d.gd
--- a/variant3d/scripts/world3d.gd
+++ b/variant3d/scripts/world3d.gd
@@ -484,10 +484,19 @@ func _sync_build_ghost() -> void:
 	# world.gd:3486: the single "mine" button resolves to the deposit under cursor.
 	if game is Object and game.has_method("resolve_mine_sid"):
 		sid = str(game.call("resolve_mine_sid", sid, wp))
 	# world.gd:3493: unknown sid draws no ghost.
 	if not Data.BUILDINGS.has(sid):
 		fx.draw_ghost("", Vector2.ZERO, false)
 		return
+	# F2-04: magnetically snap the mine preview to the deposit centre the
+	# click will use (game.gd place_building:4107-4111). Doing it here, before
+	# can_place(), keeps BOTH the ghost position and its green/red verdict on
+	# the snapped point; non-mines / no-deposit points are returned unchanged.
+	# world3d_fx.gd (B06 mesh) and input_controller.gd (B05 quad) are untouched.
+	if game is Object and game.has_method("snap_mine_pos"):
+		var snapped = game.call("snap_mine_pos", sid, wp)
+		if snapped is Vector2:
+			wp = snapped
 	var ok := false
 	if game is Object and game.has_method("can_place"):
 		var chk = game.call("can_place", 0, sid, wp)
```

**Net effect:** +41 lines, -0 lines across two files. No existing line is
deleted or rewritten; both hunks are pure insertions, so rollback is exact.

---

## 5. Backup and application instructions (governance: backup first)

COORD owns application; this agent did **not** run these commands.

1. Wait for G04 to finish gates and for COORD's exclusive-file grant (Wave G
   charter line 140). The tree is under concurrent swarm edits.
2. Take backups **outside** the repo tree, matching B05/B06 precedent:
   ```powershell
   Copy-Item variant3d\scripts\game.gd    inbox\backup\game.gd.bak-F204
   Copy-Item variant3d\scripts\world3d.gd inbox\backup\world3d.gd.bak-F204
   ```
3. Verify SHA-256 of each source and its `.bak-F204` copy matches before any
   edit (same procedure as B05 §0 / B06 §0). Record both hashes in the applying
   agent's report.
4. Apply §4 verbatim, then static-check with `git diff --check` and re-read the
   two hunks; do not weaken or update any test expectation.
5. Rollback if needed: copy the two `.bak-F204` files back over their sources.
   No other file is involved, so rollback cannot disturb B05/B06 work.
6. Hand to the runner owner (G04) for the gates in §6. **Do not run Godot from
   this ticket** — one-Godot-at-a-time still applies.

**Owner files:** `variant3d/scripts/game.gd` (new helper only) and
`variant3d/scripts/world3d.gd` (one insertion in `_sync_build_ghost()`).
**Disjointness note:** F2-03 (mill-field enlargement) may also want `game.gd`;
COORD must arbitrate so only one agent edits a given file at a time.

---

## 6. Acceptance criteria

**A — magnetic snap (the fix itself)**
1. **OBSERVED/UNVERIFIED until run:** with `hud.build_ghost_sid = "mine"` and a
   cursor point `pw` inside `MINE_SITE_RADIUS` (4 m) of an ore deposit, a probe
   that calls `world.set_build_ghost_pos(pw)` then `world._sync_build_ghost()`
   finds `world._ghost_pos` and `fx` ghost root position equal to the deposit
   centre (`dep.pos`) within 0.01 m — not `pw`. Compare in SIM space:
   `fx._ghost_root.position ≈ fx.world_pos(dep.pos)`.
2. The same probe with a non-mine sid (e.g. `hou`) reports the ghost at exactly
   `pw` — `snap_mine_pos` is a no-op there.
3. The same probe with no deposit in range returns `pw` unchanged and the
   existing `can_place` reason `"Mines must be built on an ore deposit."`.
4. The snapped ghost is green (`_ghost_ok == true`) exactly when
   `can_place(0, sid, dep.pos).ok` is true; no new false-green for empty ground.
5. Clicking at the offset `pw` places the site at `dep.pos`; ghost position and
   final site position coincide within 0.01 m (the sim already did this at
   `game.gd:4107-4111`; the check is that the preview now agrees).

**B — preserved behaviour (regressions)**
6. B06: ghost node is still `GhostBuildingFinished` with the finished/base mesh
   (`stats.ghost_mesh_source` still `finished_base|…` or `last_stage_4|…`);
   no stage-1 mesh request reappears. `t_ghost_final_stage.gd` still passes.
7. B05: `input_controller.gd` byte-identical; selection quad / marquee atoms
   (`t_select_rect.gd`, capture atom) behave exactly as before.
8. `can_place()` is byte-identical; all mine placement tests keep their current
   expectations: `t_mine_build.gd` checks `can_place_mine`, `snapped_to_deposit`,
   `builder_ordered`, build completion and the B/B2/C interruption scenarios;
   `unified_mine_test.gd` checks `preview_*`, `legal_*`, `build_*`,
   `no_deposit_rejected`, `one_mine_button`, `mine_button_name`.
9. Deposit mask untouched: no write to `mine_mask`, `_mark_mine_mask()` or
   `_clear_mine_mask()`; mapgen and tile assignment stay byte-identical.
10. Gates (runner owner only): variant selftest 29/29, uitest 17/17,
    `t_render_mode`, `assert_clean` CLEAN. No threshold lowered, no assertion
    deleted, no `expected_pre_fix_failure` flipped (CHARTER §3).

---

## 7. Preserved-by-construction (static derivation, not a PASS verdict)

| Item | Why the diff cannot touch it |
|---|---|
| B05 selection quad | No edit to `input_controller.gd`; the ghost handoff at `:1513-1515` is simply fed a snapped point downstream in `world3d.gd`. |
| B06 final-stage mesh | No edit to `world3d_fx.gd`; `draw_ghost()` still receives a sid + Vector2 and resolves the same mesh. Changing only `wp` cannot change `_ghost_resolve_mesh()`. |
| `can_place()` semantics | Function body byte-identical. It is called with a different (snapped) point for mines near a deposit — that point is one the function already accepts at `:4004-4015`. |
| Deposit mask | `game.gd` insertion is a read-only query over `res_nodes`/`_res_grid`; no `mine_mask` access. |
| Placement tests | `place_building()` loop at `:4107-4111` untouched; the new helper is additive and uncalled by the sim. |
| 2D port | `world.gd` untouched; 2D ghost still follows the raw cursor (see §8 follow-up). |
| Perf | One spatial-hash query per ghost frame over a ≤9-cell square (`MINE_SITE_RADIUS`/`RES_GRID_M`), no linear `res_nodes` scan, no new allocation of nodes/materials. Exact frame cost **UNVERIFIED** without a capture. |

---

## 8. Labels, limits and follow-ups

**PORT APPROXIMATION — NOT DONOR PARITY.** The snap radius and rule are the
port's own existing `place_building()` rule (`game.gd:19`, `:4107-4111`), not a
donor constant. No donor script line or screenshot for a magnetic mine snap was
read by this agent. **F2-02 has not landed** (§frontmatter), so donor deposit
footprint/snap truth is still open; re-check this proposal against
`reports/F2_02_donor_fields_mines.md` when it lands. If F2-02 supplies a different
snap radius or an exact donor centre definition, update both the helper and
`MINE_SITE_RADIUS` in one coordinated change — do not claim parity now.

**UNVERIFIED (no runner, no capture, no donor A/B frame):**
- All §6 checks are acceptance definitions, not results. No Godot job was run.
- Real on-screen ghost/site coincidence at the live camera is unmeasured.
- Per-frame cost of the new spatial query is unmeasured.
- Hand-edited maps with two same-type deposits inside one 4 m radius (nearest
  vs first selection) are untested; generated maps keep ore ~22 m apart.

**Out of scope / follow-ups for COORD:**
1. **2D parity (optional):** the same one-line snap can be inserted in
   `world.gd:_draw_ghost()` immediately after `_ghost_sid = sid` at `:3489`
   (`wp = game.snap_mine_pos(sid, wp)`) so the 2D hologram agrees too. Needs a
   separate file grant; deliberately excluded here to keep the diff minimal.
2. **Single source of truth (optional):** replace `game.gd:4107-4111`'s inline
   first-match loop with `pos = snap_mine_pos(sid, pos)` so ghost and site can
   never diverge on exotic maps. Behaviour-equivalent on generated maps; touches
   tested placement code, so leave to a separate ticket with a runner.
3. **F2-05:** fold §6 items 1-5 into the QA atom with a windowed before/after
   capture (cursor offset from deposit, ghost centred, mine centred, green
   verdict); composer must be an independent second agent (C04 protocol).
4. **F2-03 ownership:** if the mill-field fix also needs `game.gd`, sequence the
   two edits so the diffs do not collide.

*End of F2-04 report. Proposal only; no code edited, no runner job submitted,
no donor-parity claim.*
