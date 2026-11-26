---
id: V105
ticket: "TERRAIN-SWARM-2026-11-26 / V105 — FINAL OWNER SHEET (single page, safe to paste as today's answer)"
agent: "V105 (read-only final-owner-sheet subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V105_final_owner_sheet.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V105_final_owner_sheet.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
parity_status: UNVERIFIED
multiple_passes: true
multiple_pass_note: "Every load-bearing claim was re-read against a second landed document or a second instrument: asset count (PowerShell Get-ChildItem/Measure-Object here + V103 two-command read; both 5,256 / 358,196,527 B), key count (spec/09:11,22 + V37/V47-38 + X20), X39 existence (directory glob + Test-Path), acks (V104 §6 + V86 row 16), seam (HANDOFF §2.3 + V81 §3.3 + V86 row 14). V103/V104 landed during this read; V99/V102 did not exist at final glob — no content invented for them."
sources_read: "CHARTER.md, README.md, HANDOFF.md, REPORT_INDEX.md, spec/README.md, reports/V81_owner_decision_packet.md, reports/V103_final_report_card.md, reports/V104_ack_reasons.md, reports/V86_final_go_no_go.md, reports/V52_owner_qa.md, reports/V57_final_parity_statement.md, reports/V90_static_syntax_seal.md, reports/V95_registration_verification.md, reports/X39_ab_feasibility.md, spec/09_EDITOR_PARAMETERS.md; live filesystem re-glob."
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed by any worker, and no gate result is asserted here. Nothing in this sheet is a green verdict, a gate PASS, or a donor-match claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Read-only: file reads, one directory count (Get-ChildItem/Measure-Object), Test-Path and glob only. No source, shader, asset, config, test, result JSON, queue, runner, git, Godot or donor state changed; no donor binary executed or copied; no gate, capture or benchmark run; no reference image fabricated."
---

# V105 — FINAL OWNER SHEET (2026-11-26, paste-ready)

> **Mandatory reviewer wording (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 1. The one-sentence honest verdict

> **No — terrain is NOT cloned: the donor's terrain-relevant data formats and a small set of named functions are byte-exactly decoded and a donor-shaped, default-legacy port scaffold is on disk, but no gate was run, no admissible capture or donor GPU A/B frame exists and no runtime path was observed, so the honest verdict is `PORT APPROXIMATION` with donor parity `UNVERIFIED` and `RESULT IS NOT GOOD`.** `[D]/[U]` — verbatim lineage V57 §4, reaffirmed V81 §1, V103 §3.

## 2. Donor decode achievements — exact counts (decode integrity, not fidelity)

- **`.pattern`:** size law `S = 8+4wh+54(w−1)(h−1)` holds **710/710**, zero residual; 7 regions tile `[0,S)` **710/710**; **550,908** `Rec24`; **678/680** min/max bit-exact; corrected grid offset `G=8+(w−1)(h−1)` **13/13** bit-exact (X27 E9, X34, V81 §2.1).
- **`pattern.lib`:** **30,309,138 B** plaintext, **680** sections, **39,780** object records, **235** `BaseName`, 12 grid cross-checks bit-exact (X05/X27 E10).
- **Masks:** **4,466** terrainmask TGAs = **1,331** vanilla + **1,856** dlc5 + **1,279** src; `h = −1.1·B/255`; water at `B≥58` (F04/D03/X18).
- **Cfg:** **7** files hashed/parsed, **19 global + 13 local keys** (see correction C3), 64 families / **493** `Pattern=Freq` pairs, 22 chains / 118 active groups / 282 active entries / 86 names, 19 presets / 61 masks / 276 legend entries (F03/X20, spec/09).
- **RNG:** exact 32-bit LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²`, output `f32(s/2³²)`; **11 `SetRandomKey` + 3 `SetRandomExtKey64`** reseed sites; `mix64` refuted (D02/X21/V01).
- **Relief stamp / blend / water / tiles / maps:** `sub_755f30` **25,175 B / 6,751 instructions / 5 callers**, **three blend paths** (`Min` pivot, `HeightFieldMax` never read, `Offset` additive, divisor `4.0f`); `bmTransparency = glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`; four water literals (−1.1/−0.5/−0.25/−0.1); **124 tile ids/season**; 37-byte `.map` records **102,400/102,400** and **147,456/147,456** (D05/X12/X17/D06/F05/D04).
- **Honest ceiling — quote alongside the counts:** **4,265/18,918 (22.54%)** `cossacks.exe` and **12,254/22,384 (54.7%)** `editor.exe` *discovered* functions garbled; only **11/34** D01 anchors present (**23 absent**); packed `.bind` entropy **7.96** never unpacked; **972** `.inc` excerpts `;`-prefixed intent with execution `[U]`; no donor reference for mountains, sea, iron/coal mines, rivers or swamps (X27, X07/X36). "Whole donor decoded" is false. All above are **decode-integrity counts**, not a port tier-1 verdict.

## 3. Port implementation facts (presence only, never correctness)

- **Files — 13/13 present** (V103 two-command read): 6 tools (`decode_donor_cfg.py`, `decode_donor_pattern.py`, `decode_pattern_lib.py`, `decode_donor_masks.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`), 5 GDScript modules (`terrain_donor_data.gd`, `_gen.gd`, `_mesh.gd`, `_props.gd`, `terrain_donor_world.gd` N14 composer), 1 shader (`variant3d/shaders/terrain_donor_shader.gdshader`, V37 canonical), 1 test (`t_terrain_donor.gd`) — plus the single-applied two-file I11 seam in `main.gd`/`world3d.gd` and both SHA-exact `.bak-COORD-I11` backups. I12 is registered last in `tests/manifest.json` (**41** tests, V95); the GR-A24 literal was repointed to live `mountain_props.json` with no threshold moved (V95). `app/**` and the freeze set are byte-clean (V86 row 15, V95, V103).
- **Derived assets — 5,256 files / 786 `.json` / 358,196,527 B (~341 MiB)** under `variant3d/assets/terrain_new/**` (tiers `patterns/`, `masks/`, `atlas/`, `cfg/` + mask sub-tiers). Re-measured here by `Get-ChildItem -Recurse` (5,256 / 786) and independently by V103's PowerShell+Python pair — exact agreement. **Untracked, unvalidated, no root X15 manifest, no `schemas/` tier; presence is existence only.**
- **Backend — default-legacy seam:** `terrain_backend` defaults to `"legacy"` (`main.gd:125`, `world3d.gd:144`); exact config key `features.terrain.backend` (`main.gd:189`); only the literal `"donor"` opts in; any other value coerced to `legacy`; late switch refused after `bind()`; **no stock config key**, so no default flip. V61/V65 caller patches are applied; V86/V95 static re-reads found I07 collision/shore/cliff writes, atlas presence and I12 registration. **Runtime stream success remains `[U]` — no Godot run.** See correction C1.
- **Gates — NONE run.** No gate result exists for today's tree: all result JSONs stale (2026-11-25); `assert_clean` last read `DIRTY` with **575/582/585 unacked** — V104 supplies exact evidence-backed `ack` reasons but **ran zero acks** (§6 `NOT_RUN`); the latest preflight (V86) is **NO-GO**; no fresh 240²/320² baseline; `inbox/qa/**` is PENDING-only (no `captures/`, no `terrain_qa_report.json`); no admissible capture, no donor GPU A/B frame. Every `HANDOFF §4` cell stays `TODO(COORD)`. **Nothing here is green.**

## 4. Static PASS is NOT a gate PASS

V61/V65 report **static PASS** on six caller→callee pairs (type/arity/contract); V90 reports **13/13 STATIC PASS** (6/6 Python parse, 6/6 GDScript structure, 1/1 shader syntax) with Godot parse/smoke explicitly **not run**; V95 reports **5/5 static PASS** (manifest shape, single-literal repoint, clean `app/`, backup hashes); V55/V86 prerequisite "PASS" rows are current-bytes/filesystem checks. **Each is a line-level or filesystem verdict, not a gate result.** A gate PASS requires fresh result JSONs with mtime **after job START**, one Godot at a time via `godot_runner.py` with a unique `--id`, `selftest 29/29`, `uitest 17/17`, `t_render_mode` PASS, `scan_map ALL GREEN`, `assert_clean` **CLEAN** with 575/582/585 acknowledged with evidence-backed reasons (never deleted, never `--ignore-history`) and `app/**` byte-identical. None of that was done by this worker or by any landed report. `_call_adapt` returning `true` is dispatch, not stream production; `gen_params = {}` means decoded donor inputs are not wired (V61/V65). **Do not read a static PASS, a dry-run `--check` exit 0, a decoder self-test or a PENDING fixture as a gate.**

## 5. Three-tier landscape verdict (V15 §2; no tier above 2 exists)

Tier 1 = DONOR-GROUNDED STRUCTURE VERIFIED (donor datum matching a port byte/count/id/hash **and** D3 dump integrity); Tier 2 = SELF-CONSISTENT VISUAL / `PORT APPROXIMATION`; Tier 3 = UNVERIFIED. Tier-1 evidence is **prepared but unsigned** (D3 not run); tier-2 criteria are **drafted but unobserved** (no admissible capture); tier 2 never implies tier 1.

| Class | Highest honest tier today | Must stay UNVERIFIED |
|---|---|---|
| Hills / rolling relief | evidence prepared; no signed tier; **parity 3** | donor appearance, camera/zoom, no A/B frame |
| Mountains | tier-1 prepared; tier-2 unobserved; **parity 3** | no donor still; `terrainmeshN` chooser; prop rendering has no QA atom; "highlands" is a false positive |
| Mill fields | tier-1 prepared; tier-2 unobserved; **parity 3** | donor pixels, runtime activation of `;` callers, season confound |
| Sea | tier-1 prepared; tier-2 unobserved; **parity 3** | sea vs riverbank vs wet sand unresolved; plane Y, `hmapTex`, foam width |
| Shore / beach | tier-1 prepared; tier-2 unobserved; **parity 3** | donor pixels; pass count / `hmapTex` `[U]` after six passes |
| Forests | tier-1 prepared; tier-2 unobserved; **parity 3** | donor foliage pixels, interior lists |
| Stone quarries | **donor structure PARTIAL `[D]/[I]`**; **parity 3** | no donor asset named `quarr` (0 hits); quarry↔`stones` identity |
| Gold / iron / coal mines | tier-1 prepared; tier-2 unobserved; **parity 3** | A0 gold is `[I]`; no identifiable iron/coal still; capacity, snap, binding |
| Swamps / lakes | evidence prepared; **conversion gap** (no family exported); **parity 3** | `[*] = ;` activation; `m_swamp_12_old` 17×20 vs 18×23 PRESERVED; `lake_big := plain*2*0` not "repaired" |
| Decor | `[D]` direction only; **parity 3** | donor pixel identity, third-party camera/build |
| Rivers | **`OUT_OF_SCOPE`** pending COORD/F10; **parity 3** | no reference; inventing a ford threshold forbidden |

**No class is upgraded by this sheet.** `declared_unverified` (accepted gaps) is allowed, but non-empty `blocking_unverified` (no D3, no admissible capture, dirty runner) ⇒ `RESULT IS NOT GOOD`.

## 6. Free tools and the owner-only same-camera capture

**Free tools (none required to continue; Craft Anything Deep mode stays primary):** Ghidra 11.x (second lifter + VMT-pointer discovery for garbled functions / 23 missing anchors); IDR — Interactive Delphi Reconstructor (stripped-Delphi class/RTTI recovery); ImHex (pattern-language parser + hex view for `.pattern`/`pattern.lib`); Cutter/radare2 or RetDec (second-opinion decompilation); HxD (read-only `.map`/`.pattern` hex inspection).

**Owner-only same-camera capture — X39 Route A, the only admissible route** (the owner personally launches `C:\Games\Cossacks 3\cossacks.exe`; the assistant never executes or copies the donor): pin **size `mapsize = 0` → 320×320** (no donor 240² enum), **TerrainTypes 0 Land (`nowater2`)**, **season 0 Summer**, explicit `randkey0`/`randkey1` (mark `UNKNOWN` if `randkey0` unreadable — downgrades the comparison); camera from `data\cameras\camera.cfg` (tilt −32°, focal 400 Min=Max, dolly/SphereHeight/Length 20…58, DepthOfView 1200; record actual zoom); **1280×720 windowed**, no HUD over ROI; saved `.map` + donor PNG **outside the repo** with SHA-256; a ground-only fractional ROI confirmed on **both** frames (sky/HUD/units ⇒ UNVERIFIED, not retried until green); written attestation "donor launched by owner; assistant never executed donor". A donor PNG is **necessary but not sufficient** (`X39 §4`): same seed keys do not guarantee the same scene while `GenerateMapRandKey`, saved-map key bytes, donor FOV and `;`-corpus activation are `[U]`.

## 7. What would change the verdict

Nothing within the current rules produces a "donor match" — there is no such tier, and parity wording is forbidden. The **only conceivable chain** (conditions, not achievements) is all six of: (1) owner supplies a genuine same-size/seed/type/season/camera/ROI donor GPU frame; (2) an admissible non-blank 1280×720 candidate capture exists with `script_error_lines=0`, pinned seed/camera/size and identical ROI; (3) inputs matched and labelled (A/B-L1 same keys, or A/B-L2 importer-rendered same geometry) — unmatched seed or unverified ROI degrades to direction-only; (4) fresh gates green, not stale, `575/582/585` acknowledged, `app/**` byte-identical; (5) spec/toolchain evidence completed — §§01–14 READY, X15 root manifest, I05 atlas/I03 feed, N17 populated and signed, `blocking_unverified = []`; (6) a **demonstrated byte-identical geometry + pixel-identical frame under the proven-matched manifest**, ruled by COORD explicitly. Until **all six** hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"`. Even if every gate went green, the best honest outcome remains **"gates green / internal consistency PASS / donor parity UNVERIFIED"** — a `compare_shots.py` number, a still or a self-consistent visual score cannot substitute. Default flip to `"donor"` is a separate, deferred ticket.

## 8. Corrections to stale V52/V57 wording (second-read verified)

- **C1 — "inert backend" (V57 §5.2 item 5, R9):** stale. The accurate statement is **default-legacy and ungated**, not proven inert. V61/V65 caller patches are applied; V86 re-read I07 collision/shore/cliff writes, atlas presence, V48 patches and A24 atom; V95 closed I12 registration (41 tests) and the A24 literal. V52 already said "ungated rather than proven inert". Runtime stream success still stays `[U]` because no Godot ran. Quote **"default-legacy / opt-in-only / ungated"**, never "donor mode is inert".
- **C2 — "X39 absent" (V57 §5.1 item 4, Q5, frontmatter):** stale. `reports/X39_ab_feasibility.md` **is present** (directory glob + `Test-Path` True; V67 glob). X39 Route A supplies the owner capture procedure and 320² enum-0 pin; a donor frame is necessary but not sufficient. Do not repeat "X39 is not landed".
- **C3 — "20 keys" (V57 §1 row 4, V52 step 1, and V81 §2.1 cfg row):** stale. `globalparams.cfg` has **exactly 19 flat active keys** (`spec/09:11,22`; V37 §2; V47-38; X20 four passes) **+ 13 local keys**. F03's "20" and V81's "20 global" are authoring errors; never invent a 20th key.
- **Freshness note:** V103 and V104 **landed during this read** and are cited above; the requested V99 fix note and V102_final_blockers.md were **absent at final glob** and no content was invented for them. Counts are point-in-time — re-glob before relying on them.

---

*End of V105. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V105_final_owner_sheet.md`). Read-only: no source, shader, asset, config, test, result JSON, queue, runner, git, Godot or donor state changed; no donor binary executed or copied; no gate, capture or benchmark run; no PASS/green/parity claim asserted.*
