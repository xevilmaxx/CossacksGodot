---
id: V05
ticket: "TERRAIN-SWARM-2026-11-26 / V05 — reconcile the P01 and A06 terrain integration seams"
agent: "V05 (read-only seam reconciliation subagent)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_RUNNER_JOB__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V05_seam_reconciliation.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V05_seam_reconciliation.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor binary, donor frame, Godot process, runner job or capture was used. No claim of donor visual parity is made (CHARTER.md:43-44,125). All runtime effects below are static reads or DESIGN inferences."
scope_guard: "Read-only. No script, shader, config, asset, test, project.godot, git, queue, app/ or doc-other-than-this-report was changed. Only the patch sketch in §5 is text; it is NOT applied."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md; SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/P01_pipeline_audit.md; A06_integration.md; P06_prior_wave_distill.md
  - docs/terrain_swarm_2026-11-26/spec/13_PRIOR_WAVE_MEMORY.md
  - variant3d/scripts/world3d.gd; main.gd; config.gd; world3d_relief.gd; world3d_terrain.gd; tests/t_render_mode.gd; tests/t_terrain_only.gd
  - variant3d/shaders/terrain_tileindex.gdshader (grep only); variant3d/project.godot (grep only)
  - git rev-parse/log/status/diff + inbox/backup SHA-256 comparison
---

# V05 — one authoritative seam from P01 + A06

## 0. Method / multiple passes on contradictions (owner directive, CHARTER.md:85-93)

Three readings contradicted each other; each was re-read with a second instrument before a verdict.

| Contradiction | Pass 1 | Pass 2 | Pass 3 / verdict |
|---|---|---|---|
| `world3d.gd.bind()` extent: P01 E14 says `:604-661`; P01 §7 says `:609/642-645`; A06 E04 says `:604-692` | `read` of `world3d.gd:590-769` showed `func bind` at **604** and the `stats` dict closing at **692** | `grep` on the same file confirmed `:604`, `:609`, `:643`, `:644`, `:645`, `:650`, `:674`, `:741`, `:748` | **[O] `bind()` is 604-692.** P01's `604-661` is an undercount; its `609/642-645` anchors are exact. A06's `604-692` governs. All following citations use the current tree. |
| Git state: P01 `:11,29-34` says HEAD `e234ac9b`, audited files clean; A06 E12/E13 says HEAD `0e9783f2` with `M game.gd`, `M project.godot`, `M terrain_tileindex.gdshader` | `git rev-parse --short HEAD` → `e234ac9b`; `git status --short` → only docs modified/untracked | `git log -1 --format="%h %ci %s"` → `e234ac9b 2026-11-26 08:56:33 +0100 step`; `git diff --name-only` → only `docs/.../CHARTER.md`, `docs/.../spec/11_ASSET_CONVERSION.md`; scoped `git status --short -- <three source files>` and `-- app/` → **empty** | **[O] A06's E12/E13 conflict set is stale.** Third pass: SHA-256 of current files vs `.bak-Y08b`/`.bak-Y10`/`.bak-Y11` all differ, and grep finds the *described* edits present in the committed tree (`terrain_tileindex.gdshader:60` anisotropic, `game.gd:393/398` Y08b scoping, `project.godot:28` level 4). Backups are pre-change snapshots, not uncommitted work. P06 §5.1 `:194-204` and spec/13 `:37-38` are likewise stale on this point. |
| Does a config fallback work when `features.terrain.backend` has no default key (`config.gd:54-63` lists only `relief_stamps`)? | A06 §2.1 asserts generic `cfg.text()` suffices; `config.gd:406-408` observed | `config.gd:388-396` `value()` walks dotted parts and returns `fallback` on the first missing part | **[D] Confirmed safe.** No `config.gd` edit is required at stage 2; missing key yields `"legacy"`. |

No donor binary was opened; no Godot job was submitted (CHARTER.md:80-82).

---

## 1. Executive summary

1. **[D] The two proposals are complementary, not competing.** P01 fixes the *where* — an exclusive terrain-module choice at `world3d.gd:609` with the unchanged bind/build gate at `:642-645`, following the `world3d_relief.gd` sibling pattern (`world3d_relief.gd:86-92,120-129,183-184`). A06 fixes the *how the choice is supplied and proved* — `cfg.text("features.terrain.backend","legacy")` at `main.gd:185`, injected at **both** `make_world3d()` sites (`:587-588`, `:1104-1105`) before `bind()`, plus a stats observability hook (`world3d.gd:674-692`). Both forbid edits to the six legacy pipeline files; neither edits `game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world3d_terrain.gd`, the tileindex shader or `water3d.gd`.
2. **[O] Current tree is HEAD `e234ac9b`, source files clean** (§0). P01's line numbers govern; A06's HEAD/conflict register does not. The only uncommitted changes are in `docs/terrain_swarm_2026-11-26/` (CHARTER and spec/11 modified; reports/spec untracked), which V05 must not touch.
3. **[D] Verdict: A06 is safer on balance** — default-legacy config-driven A/B, both construction sites, explicit late-switch refusal, and a `stats.terrain_backend` proof without which an A/B capture is unverifiable. **P01 is safer on exactly one axis: file count** (one file instead of two). P01 leaves the switch value unspecified, so flipping it would mean editing `world3d.gd` itself between runs, breaking the byte-identical rollback and the A/B audit trail (P01 §7 `:405-408`; A06 §2.1 `:114-120`).
4. **[D] Authoritative seam = A06's control flow + P01's placement/invariants.** Exactly two files change: `main.gd` (4 additive insertions) and `world3d.gd` (const + var + setter + one ternary at `:609` + two additive stats keys). No other file changes at stage 2; no `config.gd` edit; no `tests/manifest.json` edit; `app/**` byte-untouched.
5. **[U] No donor parity claim, no gate result and no visual verdict.** The fresh `terrain_donor_world.gd` does not exist yet (glob over `variant3d/scripts/terrain_donor*` returned no files); donor constants are still being decoded by waves D/F. All of §4-§5 is a design specification, not an applied patch.

---

## 2. Evidence table (current tree, [O] unless labelled otherwise)

| ID | Source (file:line) | Observation | Label |
|---|---|---|---|
| E01 | `variant3d/scripts/world3d.gd:108` | `const TERRAIN_SCRIPT := "res://scripts/world3d_terrain.gd"` — single dynamic terrain script constant. | [O] |
| E02 | `world3d.gd:113-116` | `RELIEF_SCRIPT := "res://scripts/world3d_relief.gd"` — sibling module already composed with zero producer edits. | [O] |
| E03 | `world3d.gd:133-139` | One instance var per module: `terrain`, `entities`, `fx`, `fog`, `anim`, `relief`. | [O] |
| E04 | `world3d.gd:213-226` | `_instantiate(path)` loads dynamically, checks `can_instantiate()`, `add_child`, returns `Node` or `null`. No `class_name` (`:6-8`). | [O] |
| E05 | `world3d.gd:231-238` | `_has_height_source(g)` — gate requires a dict with `height`, or a live `PackedFloat32Array` `height`. | [O] |
| E06 | `world3d.gd:604,608-614,629` | `bind(g,h)` sets `game/hud/view_scale`; instantiates all six modules inside `if not _modules_ready`; sets `_modules_ready = true` at 629. | [O] |
| E07 | `world3d.gd:609` | `terrain = _instantiate(TERRAIN_SCRIPT)` — the sole terrain construction point. | [O] |
| E08 | `world3d.gd:642-645` | `if terrain != null: terrain.bind(game); if _has_height_source(game): terrain.build()` — unchanged gate. | [O] |
| E09 | `world3d.gd:649-650` | `if relief != null: relief.bind(game, terrain)` — relief depends on terrain's `height_at_world`. | [O] |
| E10 | `world3d.gd:674-692` | `stats` dict with additive-safe shape (`composition`, `modules{}`, `view_scale`, `relief_props`); test atoms read keys by string (`t_terrain_only.gd:509,572-573,587,605-609`). | [O] |
| E11 | `world3d.gd:741,748-751` | `has_chunk_or_fallback()` / `height_at_world()` delegate to `terrain` — the four-method + hook contract. | [O] |
| E12 | `world3d_relief.gd:3-8,86-92,120-129,183-184` | Read-only sim guard; `bind(g, terrain_module)`; stamps read via `game.get("pattern_stamps")`; Y from `terrain.height_at_world()`. | [O] |
| E13 | `main.gd:120-124` | `var render_mode := "2d"` with an explicit warning not to put `3d` on that line. | [O] |
| E14 | `main.gd:179-186` | `cfg.load_all/apply`; `cfg.text("gameplay.screenshot_focus",...)` `:182`; `render_mode = str(cfg.text("gameplay.render_mode","2d")).to_lower()` `:185`; `Data.RENDER_MODE = render_mode` `:186`. | [O] |
| E15 | `main.gd:586-589` and `main.gd:1103-1106` | Two independent `if render_mode == "3d"` sites, each `world = make_world3d()` then `world.bind(game)`; `make_world3d()` defined at `:1037-1045`. | [O] |
| E16 | `main.gd:1338,1342` | `--config` and `--dump-config` flags exist for a temp A/B override; no committed file needed. | [O] |
| E17 | `config.gd:46-63,54-63` | `features.terrain` table exists; only `relief_stamps` key at `:62` — no `backend` default yet. | [O] |
| E18 | `config.gd:388-396,406-408` | `value()` dotted lookup returns `fallback` on a missing part; `text()` returns `str(v)` or fallback. | [O] |
| E19 | `config.gd:441-442` | `feature_terrain_relief_stamps()` is the typed-accessor pattern to copy only if a config owner later wants one. | [O] |
| E20 | `t_render_mode.gd:34-42,79-100,120-126` | Regexes pin the declared 2D default, `make_world3d`/`make_camera3d` presence, `src.count("make_world3d")>=2`, and legacy constructors/binds. A `"legacy"` variable and `has_method` guard match none of these patterns. | [O]/[D] |
| E21 | `world3d_terrain.gd:131,349,926,969,1089,1170,1220,1447-1464,1492,1714,1722` | Legacy contract actually used: `bind`, `build`, `invalidate`, `height_at_world`, `has_chunk_or_fallback`, `stats`; exactly one `HeightmapTerrain` mesh + one water module + one environment per `build()` (`:1461-1464`). | [O] |
| E22 | `git rev-parse --short HEAD` + `git status --short` + `git diff --name-only` (two passes, §0) | HEAD `e234ac9b`; only two docs modified; all six pipeline files and `app/` clean. | [O] |
| E23 | SHA-256 comparison `game.gd`/`.bak-Y08b`, `project.godot`/`.bak-Y11`, shader/`.bak-Y10`; grep `:60`/`:393,398`/`:28` | Backups differ from the committed files; the described Y08b/Y10/Y11 changes are present **in HEAD**, not uncommitted. | [O] |
| E24 | glob `variant3d/scripts/terrain_donor*` | No donor module exists yet; A06's `terrain_donor_world.gd` (N1) is a future file. | [O] |
| E25 | `reports/V04_tree_conflicts.md` — glob `**/V04*tree*` returned no files; SWARM_BOARD.md:6-40 has no V04 row | V04 report is **not landed**; its exact findings are [U]. spec/13 `:37-38` only says "V04 worker is auditing hashes and rollback". | [O]/[U] |

---

## 3. The two proposals compared

| Axis | P01 (§7 `:381-422`, §8 `:435-437`) | A06 (§2.1 `:79-133`, §2.2 `:134-158`) | Reconciled verdict |
|---|---|---|---|
| Composition point | `world3d.gd:609` — instantiate donor **instead of** legacy; keep `:642-645` unchanged | same (`world3d.gd:609` ternary); "everything else at `:641-692` stays" | **Identical.** No conflict. |
| How the switch is chosen | "one `const DONOR_TERRAIN_SCRIPT` and a switch in `world3d.gd.bind()`" — the value source is unspecified / COORD-owned by direct edit | `cfg.text("features.terrain.backend", "legacy")` at `main.gd:185`, injected at both sites via `set_terrain_backend()` | **Adopt A06.** P01's unspecified source would require editing the seam file to A/B, defeating byte-identical rollback and making captures unauditable (E10/E16). |
| Files edited | `world3d.gd` only | `main.gd` + `world3d.gd` (optionally `config.gd` at stage 4) | A06 costs one extra file; P01 wins on file count only. |
| Legacy pipeline edits | none of the six files (`game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world3d_terrain.gd`, shader, `water3d.gd`) | none of the six (§2.6 `:255-259`) | **Identical — adopt as a binding invariant.** |
| Default / rollback | legacy retained behind switch; no named default | explicit `"legacy"` default, normalised from any unknown value; three `Copy-Item` rollback | **Adopt A06** (CHARTER.md:57-61 requires legacy retained until A/B). |
| Both construction sites | not addressed | `:587-588` and `:1104-1105`, both before `bind()` | **Adopt A06** — otherwise selftest and skirmish can use different backends (A06 §5 risk 1). |
| Observability | none specified | `stats.terrain_backend` + chosen script path at `world3d.gd:674-692` | **Adopt A06** — without it a capture cannot prove which backend ran. |
| Late switch | not addressed | refuse after `bind()` (`push_error`, keep current module) | **Adopt A06** — a mid-game swap orphans water/relief nodes (E21). |
| Sibling pattern | reuse `world3d_relief.gd` proof (`:86-92,120-129`) | N5 is a *separate* props module; does not replace `world3d_relief.gd` (§2.2 N5) | **Compatible:** keep `world3d_relief.gd` bound at `:649-650` in both modes; the donor module may add its own props later, but must not double-build. |
| Stacked-node hazard | explicitly flagged (P01 R1 `:447`) | one plane / one mesh / one environment (A06 §2.5 `:238-241`) | **Adopt both:** exclusivity at `:609` is the mechanism; one-node invariants are the gate. |
| Line numbers / git state | correct for current tree (`e234ac9b`, clean) | HEAD `0e9783f2` + 3 dirty source files — **stale** (§0) | **P01's version note governs**; re-read before applying regardless (A06 §6.3 `:375`). |

**[I] Why A06 is safer, stated plainly:** P01's one-file seam is a smaller collision surface, but it leaves no runtime-configurable, observable, default-legacy switch; a P01-only implementation would have to change `world3d.gd` source to A/B and to revert, which is exactly the "byte-identical legacy rollback" property the charter demands (CHARTER.md:57-61, A06 §2.5 `:244-249`). A06 pays one extra file and a handful of additive lines to buy a named config key, an A/B override through an existing flag, a two-site consistency guarantee, and proof in `stats`. Its extra risks (t_render_mode regex, missed second site, null `world`) are all detectable and have concrete guards (E20, §4 step 2/3). **P01 is retained as the binding placement spec and as the "no legacy edits" guard; A06 is retained as the control-flow spec.**

---

## 4. Authoritative seam (one specification)

All line numbers are the current tree (HEAD `e234ac9b`, §0). **Exactly two files change; everything else is byte-identical.**

### 4.1 Call flow (current + proposed inserts marked `+`)

```
config.json / --config  (main.gd:179-184)
  → cfg.text("features.terrain.backend","legacy")      [+] after main.gd:186
  → terrain_backend ∈ {"legacy","donor"}               [+] normalised
  → main.gd:587  world = make_world3d()                    (path 1: staged load)
      [+] world.set_terrain_backend(terrain_backend)
    main.gd:588  world.bind(game)
  → main.gd:1104 world = make_world3d()                    (path 2: _setup_full_game)
      [+] world.set_terrain_backend(terrain_backend)
    main.gd:1105 world.bind(game)
  → world3d.gd:604 bind(g,h)
      :609 terrain = _instantiate(DONOR if backend=="donor" else LEGACY)   [edited]
      :610-614 other five modules unchanged (relief sibling at :614)
      :629 _modules_ready = true  [+ _terrain_locked = true]
      :642-645 terrain.bind(game) → if _has_height_source(game): terrain.build()  [UNCHANGED]
      :649-650 relief.bind(game, terrain)  [UNCHANGED]
      :674-692 stats  [+ "terrain_backend", + "terrain_script"]
  → world3d.gd:741/748 has_chunk_or_fallback()/height_at_world() delegate to `terrain` [UNCHANGED]
```

### 4.2 Exact edits

1. **`variant3d/scripts/main.gd` (COORD-owned) — 4 additive inserts.**
   - After `:124` (`var render_mode := "2d"`): `var terrain_backend := "legacy"`. **[D] Do not touch `:120-124`** — `t_render_mode.gd:35-42` regexes target that declaration and the `gameplay.render_mode` fallback; a separate line with a `"legacy"` literal matches none of them.
   - After `:185-186`: read `terrain_backend = str(cfg.text("features.terrain.backend", "legacy")).to_lower()`, then coerce anything other than `"donor"` back to `"legacy"`. **[D] Safe with no `config.gd` edit** (E18). A `--config` temp JSON `{"features":{"terrain":{"backend":"donor"}}}` selects A/B; never commit it (A06 §2.1 `:129-132`).
   - Between `:587` and `:588`, and again between `:1104` and `:1105`: `if world != null and world.has_method("set_terrain_backend"): world.set_terrain_backend(terrain_backend)`. **[D] Both sites are mandatory** (E15); the `null` check is added beyond A06's `has_method()` guard because `make_world3d()` can return `null` (`:1038-1045`).
2. **`variant3d/scripts/world3d.gd` (COORD-owned).**
   - Beside `:108-116`: `const TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"`. This is the concrete member of P01's `terrain_donor_*.gd` wildcard (E24) and A06's N1 path.
   - Beside `:133-139`: `var terrain_backend := "legacy"` and `var _terrain_locked := false`.
   - Add `func set_terrain_backend(mode: String) -> void` near the helpers at `:211-226`: if `_terrain_locked`, `push_error` and return without changing anything; else set `"donor"` only for an exact lowercased `"donor"`, otherwise `"legacy"`. The setter runs **before** `bind()` from both sites; `_terrain_locked` is set at `:629`, so late swaps are refused (A06 §2.1 `:107-109`).
   - Replace `:609` with the ternary in §4.1. One module is instantiated — never both (P01 R1 `:447`, E21).
   - Add `_terrain_locked = true` next to `_modules_ready = true` at `:629`.
   - Add only two keys to the `stats` dict at `:674-692`: `"terrain_backend": terrain_backend` and `"terrain_script": <chosen path>`. **Do not rename, remove or re-type any existing key** (E10).
3. **New file (future ticket, not this report): `variant3d/scripts/terrain_donor_world.gd`.** Public surface exactly `bind(game)`, `build() -> bool`, `invalidate()`, `has_chunk_or_fallback()`, `height_at_world(Vector2) -> float`, `stats` (A06 N1 `:143`; P01 §7 `:403-404`). No `class_name` (`world3d.gd:6-8`), tabs only, read-only on all sim state (`world3d_relief.gd:3-8`), owns its own stage pipeline, atlas/manifest read-only, exactly one mesh/water/environment (A06 §2.5 `:237-241`).
4. **No `config.gd` edit at stage 2** (E18/E19). A typed `feature_terrain_backend()` or a `backend` default in `FEATURES_DEFAULTS` (`config.gd:54-63`) is a separate config-owner/stage-4 ticket (A06 §2.4 `:219-223`).

### 4.3 What stays byte-identical (binding)

- `variant3d/scripts/game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world3d_terrain.gd`, `shaders/terrain_tileindex.gdshader`, `shaders/water3d.gdshader`, `scripts/water3d.gd` — **zero edits** (P01 §7 `:414-416`; A06 §2.6 `:255-259`).
- `world3d_relief.gd`, `config.gd`, `project.godot`, `tests/manifest.json`, all `tests/t_*.gd`, `inbox/backup/**`, `app/**` — zero edits at stage 2.
- In `world3d.gd`, lines `:610-614`, `:631-672` (feed resets, module binds, fog aliasing) and `:694-769` are untouched; `stats` changes are **additive only**.
- In `main.gd`, the `render_mode` declaration block `:120-124`, the 2D branches (`:590-593`, `:1119-1122`), and every other line except the four inserts stay untouched.
- Legacy backend output (mesh, UV2, dump bytes, stats keys, node names) must remain byte-identical to today's tree; the donor backend is held only to structural invariants (A06 §2.5 `:244-249`, E21). **No parity claim.**

---

## 5. Minimal patch sketch — TEXT ONLY, NOT APPLIED

```diff
# === variant3d/scripts/main.gd (COORD) ===
@@ after current :124  var render_mode := "2d"
+var terrain_backend := "legacy"

@@ after current :185-186  (render_mode read + Data.RENDER_MODE)
+	terrain_backend = str(cfg.text("features.terrain.backend", "legacy")).to_lower()
+	if terrain_backend != "donor":
+		terrain_backend = "legacy"

@@ current :587-588 (path 1: staged loader)
 	if render_mode == "3d":
 		world = make_world3d()
+		if world != null and world.has_method("set_terrain_backend"):
+			world.set_terrain_backend(terrain_backend)
 		world.bind(game)

@@ current :1104-1105 (path 2: _setup_full_game) — identical insertion
 	if render_mode == "3d":
 		world = make_world3d()
+		if world != null and world.has_method("set_terrain_backend"):
+			world.set_terrain_backend(terrain_backend)
 		world.bind(game)

# === variant3d/scripts/world3d.gd (COORD) ===
@@ beside current :108-116 (module constants)
+const TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"

@@ beside current :133-139 (module instances)
+var terrain_backend := "legacy"
+var _terrain_locked := false

@@ near current :211-226 (_instantiate helpers)
+func set_terrain_backend(mode: String) -> void:
+	if _terrain_locked:
+		push_error("world3d: terrain backend locked after bind()")
+		return
+	terrain_backend = "donor" if str(mode).to_lower() == "donor" else "legacy"

@@ current :609 (sole terrain construction point)
-		terrain = _instantiate(TERRAIN_SCRIPT)
+		terrain = _instantiate(TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT)

@@ current :629 (first-bind completion)
 		_modules_ready = true
+		_terrain_locked = true

@@ current :674-692 (stats dict — APPEND ONLY, no key renamed/removed)
+		"terrain_backend": terrain_backend,
+		"terrain_script": TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT,
```

**Not in this patch:** `terrain_donor_world.gd` and its stage modules, any shader/asset, any test registration, any `.bak` creation, any config default. Those belong to A06's staged rollout (§2.2/§2.4) and to COORD-assigned implementation tickets.

---

## 6. Conflict register — V04 and the uncommitted tree

1. **[O] `reports/V04_tree_conflicts.md` is not landed** (E25); SWARM_BOARD.md has no V04 row. spec/13 `:37-38` only notes "V04 worker is auditing hashes and rollback". Therefore V04's exact findings are **[U]** and cannot be reconciled line-by-line here.
2. **[O] Current two-pass git state:** HEAD `e234ac9b`; the only tracked modifications are `docs/terrain_swarm_2026-11-26/CHARTER.md` and `docs/.../spec/11_ASSET_CONVERSION.md`; numerous `docs/...` reports/spec files are untracked; `git status --short -- app/` and for the six pipeline files is **empty** (E22).
3. **[O] A06's conflict register is stale.** A06 E12 `:69` and §2.6 `:255-259` describe `M game.gd`, `M project.godot`, `M terrain_tileindex.gdshader` at HEAD `0e9783f2`. Two passes plus a third backup-byte/hash comparison (§0) show those edits are **committed at `e234ac9b`** and the working tree matches HEAD (E23). The `.bak-Y08b`/`.bak-Y10`/`.bak-Y11` files are stale pre-change snapshots, not live uncommitted work.
4. **[D] Practical consequence for COORD:** A06's §3.4 "forbidden" list (`git reset --hard`, `git checkout -- .`, `git clean -fd`, copying from `git show HEAD`) is still safe to keep as a discipline, but its *stated reason* no longer holds. The file-scoped `Copy-Item` + recorded SHA-256 recipe (A06 §3.1-§3.3) remains the authoritative rollback method; do not "normalise" the three files and do not delete any `.bak`.
5. **[D] No seam conflict with V04's likely domain:** V05 touches no source file, so whichever hash/rollback discrepancies V04 reports, they are inputs to COORD's integration decision, not obstacles to this specification. If V04 later lands a finding that `main.gd`/`world3d.gd` differ from HEAD, **re-read those two files before applying §5** (A06 §6.3 `:375`; P01 version note `:11`).
6. **[D] Doc-level conflict to avoid:** CHARTER.md and spec/11 are modified by other workers; V05 writes only `reports/V05_seam_reconciliation.md` (CHARTER.md:73-75).

---

## 7. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | Donor and legacy branches both build → two meshes / two water planes / two `WorldEnvironment` nodes | [D] high | `world3d_terrain.gd:1447-1464`; exclusivity at `world3d.gd:609` is the only mechanism. Never add the donor as a third parallel sibling. |
| R2 | Switch applied at only one `make_world3d()` site → selftest and skirmish use different backends | [D] high | E15; insert at both `:587-588` and `:1104-1105` in one commit; assert `stats.terrain_backend` in both paths. |
| R3 | `set_terrain_backend()` called after `bind()` → orphaned water/relief nodes or a half-built world | [D] high | `world3d.gd:629,642-650`; `_terrain_locked` + `push_error`; setter keeps current module. |
| R4 | `world` is `null` (failed `make_world3d()`) and the guard calls a method on null | [D] medium | `main.gd:1038-1045`; add the `world != null` check (§4.2 item 1). |
| R5 | `t_render_mode` fails because a new variable is mistaken for a render-mode literal or the declaration block shifts | [D] medium | `t_render_mode.gd:34-42,79-100`; keep `:120-124` byte-identical, put the new var after `:124`, `"legacy"` matches no `b1/b2/b3`. |
| R6 | `_has_height_source()` gate blocks the donor `build()` if the donor module does not consume the legacy dump | [D] medium | `world3d.gd:231-238,644`; authoritative spec keeps the gate unchanged, so the donor module must honour the dump keys (A06 §2.3 `:176-192`) or COORD must approve a separate backend-aware gate ticket. |
| R7 | Additive `stats` keys break an atom that compares the whole dict | [D] low-medium | E10; atoms read named keys by string; keep all existing keys/values byte-identical. |
| R8 | New module writes sim state or adds RNG draws → seed replay / 2D gates drift | [D] high | `world3d_relief.gd:3-8`; read-only guard, separate stream, same-seed replay (A06 §2.3, P01 §5). |
| R9 | Unknown config value silently activates donor | [D] medium | `config.gd:406-408`; normalise everything except exact `"donor"` back to `"legacy"`. |
| R10 | Stale reports (A06 E12, P01 E14, P06 §5.1, spec/13) drive a wrong line edit or destructive restore | [O]/[D] medium | §0 / §6; P01's version note governs, re-read immediately before any edit. |
| R11 | Donor tile ids/heights cannot satisfy UV2 `[0,123]`, `[16,8]` atlas or one-water-plane invariants without a new contract | [U] high | A06 §2.5 `:237-241`, §6.5 `:377`; D08/F05 findings not yet landed. |
| R12 | Donor constants (blur kernel, blend/clamp, relief grids, water Y, face promotion) remain unrecovered; a "better looking" result is mistaken for parity | [U]/PORT APPROXIMATION high | CHARTER.md:40-44,83-84; label everything; no verdict without a real matched-seed donor GPU A/B (A06 §2.4 `:216-217`). |

---

## 8. UNVERIFIED register

1. **[U] No donor binary, donor data, donor frame, Godot process, runner job, capture or gate was used by V05.** No donor parity claim; none is possible under CHARTER.md:43-44,125.
2. **[U] V04's report has not landed** (E25). Its hash/rollback findings cannot be cross-checked line-by-line; §6 records only V05's own two-pass observations.
3. **[U] `terrain_donor_world.gd` does not exist** (E24). The entire new-module contract in §4.2 item 3 is a design requirement, not an observed implementation.
4. **[U] The exact line numbers in §4-§5 are current-tree only** (`e234ac9b`). They drift with any commit; re-read `main.gd`/`world3d.gd` before applying.
5. **[U] `features.terrain.backend` is not in `FEATURES_DEFAULTS`** (`config.gd:54-63`): the runtime key is introduced only by the §5 `main.gd` read; whether to add a typed default/accessor is a config-owner decision (A06 §6.7 `:379`).
6. **[U] Whether the donor module can satisfy `_has_height_source()` and the four-method contract without inheriting port substitutions** (P01 §7 `:409-413`) — depends on D/F spec findings.
7. **[U] Whether donor tile ids fit the existing 124-name `[16,8]` atlas** (`t_terrain_only.gd:598-609`; A06 §6.5 `:377`) and whether `height_at_world()` stays within the 0.001 m / 0.02 m tolerance (A06 §6.6 `:378`).
8. **[U] Whether adding `stats.terrain_backend` affects any gate that snapshots the full `stats` dict** — E10 shows named-key reads, but not every atom was exhaustively enumerated.
9. **[U] Stage-3/4 outcomes** (A/B threshold, default flip, legacy retirement) are future COORD/owner decisions; A06's gate list is quoted, not measured.
10. **[U] The `world3d_relief.gd` props vs donor-owned props boundary**: both proposals leave `relief.bind(game, terrain)` at `:649-650`; whether a donor module should also emit `terrainmesh` silhouettes is engine-side and unresolved (P01 open Q3 `:488-489`).

---

## 9. Open questions

1. **Q1 (COORD):** Confirm A06 as the control-flow spec and P01 as the placement/no-legacy-edits spec; name the single owner of `main.gd` and `world3d.gd` for the four+four additive inserts (A06 Q1 `:384`; SWARM_BOARD.md:48-53).
2. **Q2 (COORD/V04):** When `V04_tree_conflicts.md` lands, does it find any source-file hash discrepancy beyond the stale A06 E12 register? If yes, re-read before applying §5.
3. **Q3 (COORD):** Is `stats.terrain_backend`/`stats.terrain_script` the agreed A/B proof key, or should N11 (`t_terrain_donor.gd`) pin a golden dump hash instead (A06 Q5 `:388`)?
4. **Q4 (A05/G04):** What matched-seed capture + histogram constitutes stage-3 acceptance when no donor frame may be ground truth (A06 Q2 `:385`)?
5. **Q5 (config owner):** Add `backend` to `FEATURES_DEFAULTS` (`config.gd:54-63`) and a typed accessor (`config.gd:441-442` pattern), or keep the generic `text()` read permanently (A06 Q6 `:389`)?
6. **Q6 (T-MOD/A03):** Confirm `terrain_donor_world.gd` as the exact N1 path and that the donor module reuses `water3d.gd` read-only rather than creating a second water implementation (A06 N1/N6 `:143,148`).
7. **Q7 (COORD):** If the donor module cannot consume the legacy dump, is a backend-aware replacement for `_has_height_source()` (`world3d.gd:231-238,644`) a new owned ticket, or must the donor module adapt to the existing dump?
8. **Q8 (COORD):** Does `world3d_relief.gd` stay bound at `:649-650` in donor mode, or is a donor-owned props module a separate approved contract change (§8 item 10)?

---

## 10. Handoff summary (5 lines)

1. **Verdict:** P01 and A06 are complementary — P01 owns the *where* (`world3d.gd:609`, gate `:642-645` unchanged), A06 owns the *how/proof* (`main.gd:185` config read, both sites `:587-588`/`:1104-1105`, `stats.terrain_backend`); A06 is safer on balance, P01 only on file count.
2. **Authoritative seam:** two files only — `main.gd` (4 additive inserts) and `world3d.gd` (const + 2 vars + late-switch-refusing setter + ternary at `:609` + `_terrain_locked` at `:629` + 2 additive stats keys); default `"legacy"`, unknown values coerced to legacy.
3. **Byte-identical:** the six legacy pipeline files, relief/config/project/tests/atlas/`app/**`, all of `world3d.gd:610-614,631-672,694-769`, and the `render_mode` block `main.gd:120-124`; legacy-mode output must not drift.
4. **Conflicts:** V04 report not landed ([U]); current HEAD `e234ac9b` with source files clean — A06's E12/E13 uncommitted-edit register and P01 E14's `604-661` span are stale; re-read before applying (multi-pass evidence §0).
5. **Patch sketch is text only, not applied**; no donor module exists yet, no Godot job or capture was run, and **no donor parity claim** is made (PORT APPROXIMATION / UNVERIFIED throughout).

*End of V05. Exactly one report written; no source, shader, config, asset, test, git, donor, Godot or runner state changed.*
