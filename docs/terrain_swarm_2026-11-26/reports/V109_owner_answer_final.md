---
id: V109
ticket: "TERRAIN-SWARM-2026-11-26 / V109 — definitive OWNER ANSWER (one page, zero overstatement)"
agent: "V109 (read-only final owner-answer subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
parity_status: UNVERIFIED
verdict: "RESULT IS NOT GOOD"
multiple_passes: true
multiple_pass_note: "Two verification passes. P1 = full reads of CHARTER, HANDOFF, REPORT_INDEX, spec/README, V105, V103, V104, V67, X39. P2 = live read-only re-check by two independent instruments (PowerShell Get-ChildItem/Test-Path/Select-String/git ls-files AND Python os.walk/getsize): 13/13 impl files, X39 present, asset tree, main.gd:125/189 + world3d.gd:118/144/624 seam, spec/09:11,22 = 19 keys, inbox/qa PENDING-only, 4 tracked large files. No claim rests on a single read."
snapshot_note: "Live swarm still moving: V103/V105 cross-verified 5,256 files / 786 .json / 358,196,527 B; the V109 dual-instrument re-glob reads 5,257 / 787 / 364,646,949 B. Both are point-in-time, presence-only and unverified — no byte validation, no gate. Re-glob before relying on any count."
sources_read: "CHARTER.md, HANDOFF.md, REPORT_INDEX.md, spec/README.md, spec/09_EDITOR_PARAMETERS.md, reports/V105_final_owner_sheet.md, V103_final_report_card.md, V104_ack_reasons.md, V67_owner_answer_check.md, X39_ab_feasibility.md; live filesystem + git re-read."
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed by any worker, and no gate result is asserted here. Nothing in this answer is a green verdict, a gate PASS or a donor-match claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Read-only: file reads, glob, Test-Path, Select-String, Get-ChildItem/Measure-Object, Python os.walk/getsize and git read commands only. No source, shader, asset, config, test, result JSON, queue, runner, git index, Godot or donor state changed; no donor binary executed or copied; no gate, capture or benchmark run; no reference image fabricated."
---

# V109 — DEFINITIVE OWNER ANSWER (2026-11-26)

> **Mandatory reviewer wording (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 1. The one-sentence answer

> **No — terrain is NOT cloned. The donor's terrain-relevant data formats and a small set of named functions are byte-exactly decoded, and a donor-shaped, default-legacy port scaffold is on disk, but no gate was run, no admissible capture or donor GPU A/B frame exists and no runtime path was observed — so the honest verdict is `PORT APPROXIMATION` with donor parity `UNVERIFIED` and `RESULT IS NOT GOOD`.** `[D]/[U]` — verbatim lineage V57 §4 → V81 §1 → V103 §3 → V105 §1; re-verified here. "Terrain is not cloned" and "RESULT IS NOT GOOD" are the owner-facing bottom line; there is no PASS, green or parity tier anywhere in this answer.

## 2. Donor decode achievements — exact counts, with limitations

**What is byte-exact (decode integrity, NOT fidelity or a port verdict):**

- **`.pattern`:** size law `S = 8+4wh+54(w−1)(h−1)` holds **710/710**, zero residual; 7 regions tile `[0,S)` **710/710**; **550,908** `Rec24`; **678/680** min/max bit-exact; corrected grid offset `G=8+(w−1)(h−1)` **13/13** bit-exact.
- **`pattern.lib`:** **30,309,138 B** plaintext, **680** sections, **39,780** object records, **235** `BaseName`; 12 grid cross-checks bit-exact.
- **Masks:** **4,466** terrainmask TGAs = **1,331** vanilla + **1,856** dlc5 + **1,279** src; `h = −1.1·B/255`; water at `B≥58`.
- **Cfg:** **7** files hashed/parsed; **19 global + 13 local keys** (not 20 — see §7); 64 families / **493** `Pattern=Freq` pairs; 22 chains / 118 active groups / 282 active entries / 86 names; 19 presets / 61 masks / 276 legend entries.
- **RNG:** exact 32-bit LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²`, output `f32(s/2³²)`; **11 `SetRandomKey` + 3 `SetRandomExtKey64`** re-seeds; `mix64` refuted.
- **Relief / blend / water / tiles / maps:** `sub_755f30` **25,175 B / 6,751 instructions / 5 callers**, three blend paths (`Min` pivot, `HeightFieldMax` never read, `Offset` additive, divisor `4.0f`); `bmTransparency = glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`; four water literals (−1.1/−0.5/−0.25/−0.1); **124 tile ids/season**; 37-byte `.map` records **102,400/102,400** and **147,456/147,456**.

**Limitations that must be quoted alongside every count:**

- **Garbled code:** **4,265/18,918 (22.54%)** `cossacks.exe` and **12,254/22,384 (54.7%)** `editor.exe` *discovered* functions are garbled/unstructured; only **11/34** D01 terrain anchors are present (**23 absent**). "Whole binary decoded" is false.
- **Packed stub:** five PEs carry a **146,800-byte**, entropy-**7.965** `.bind`/`WUS1` tail = **835,376 / 29,987,184 B (2.786%** of seven PEs; **2.152%** of the two terrain-relevant PEs). A partial static decoder recovered the GetPC OEP, but the residual payload was **never unpacked or executed** — absence of strings/functions there is `[U]`, not proof.
- **Runtime intent, not execution — the single largest categorical gap:** all **972** `.inc` excerpts and all cfg literals are `;`-prefixed intent; no donor binary was run, so no compiled path was ever observed consuming a decoded value. Pass count, `hmapTex` bind/plane Y, native kernels, `.pattern`/`.map` field semantics and `GenerateMapRandKey` stay `[U]`; every port visual stays `PORT APPROXIMATION`. "Every single bit" was **not achievable under the read-only/no-execution charter and was not achieved** (X27 ceiling). There is no reliable donor still for mountains, sea, iron/coal mines, rivers or swamps.

## 3. Port state — presence only, never correctness

- **13/13 implementation files present** (dual-instrument re-check): 6 tools (`decode_donor_cfg.py`, `decode_donor_pattern.py`, `decode_pattern_lib.py`, `decode_donor_masks.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`), 5 GDScript modules (`terrain_donor_data.gd`, `_gen.gd`, `_mesh.gd`, `_props.gd`, `terrain_donor_world.gd` N14 composer), 1 shader (`terrain_donor_shader.gdshader`, V37 canonical), 1 test (`t_terrain_donor.gd`) — plus the single-applied two-file I11 seam and both SHA-exact `.bak-COORD-I11` backups (present, re-verified).
- **5,256 derived assets** (V103 + V105, two instruments each, exact agreement): **5,256 files / 786 `.json` / 358,196,527 B (~341 MiB)** under `variant3d/assets/terrain_new/**` (tiers `patterns/`, `masks/`, `atlas/`, `cfg/`). V109 live re-glob reads **5,257 / 787 / 364,646,949 B** — the set is still growing; both figures are point-in-time. **Untracked, unvalidated, no root X15 manifest, no `schemas/` tier; presence is existence only.**
- **Default-legacy seam (verified live):** `terrain_backend` defaults to `"legacy"` (`main.gd:125`, `world3d.gd:144`); exact config key `features.terrain.backend` (`main.gd:189`); only the literal `"donor"` opts in (`world3d.gd:624`); late switching refused after `bind()`; **no default flip**. It is **default-legacy / opt-in-only / ungated**, **not "inert"** — V61/V65 caller patches are applied and give static PASS on six pairs; runtime stream success remains `[U]` because no Godot ran.
- **No gates were run.** All result JSONs are stale (2026-11-25); `assert_clean` last read `DIRTY` with **575/582/585 unacked** — V104 supplies exact evidence-backed `ack` reasons but **ran zero acks**; V86 preflight is **NO-GO**; no fresh 240²/320² baseline; `inbox/qa/**` is PENDING-only (live: `PENDING_N19_captures.md`, `PENDING_N7_validate_terrain_new.md`, `terrain_qa_report.json.PENDING`, `OWNER_CAPTURE_TEMPLATE.md`, `README.md`; **no `captures/`, no `terrain_qa_report.json`**); every `HANDOFF §4` cell stays `TODO(COORD)`. **Nothing is green.**
- **Static PASS ≠ gate PASS:** V61/V65 (six type/arity/contract pairs), V90 (**13/13 STATIC PASS**: 6/6 Python parse, 6/6 GDScript structure, 1/1 shader syntax), V95 (**5/5** static PASS) are line-level/filesystem verdicts with Godot parse/smoke explicitly **not run**. A gate PASS requires fresh result JSONs with mtime **after job START**, one Godot at a time via `godot_runner.py` with a unique `--id`, `selftest 29/29`, `uitest 17/17`, `t_render_mode` PASS, `scan_map ALL GREEN`, `assert_clean` **CLEAN** with 575/582/585 acknowledged (never deleted, never `--ignore-history`) and `app/**` byte-identical. None of that was done. `_call_adapt` returning `true` is dispatch, not stream production; `gen_params = {}` means donor inputs are not wired.

## 4. Three-tier landscape verdict — V15 §2, no tier above 2, nothing upgraded

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

**No class is upgraded by this answer.** `declared_unverified` (accepted gaps) is allowed, but non-empty `blocking_unverified` (no D3, no admissible capture, dirty runner) ⇒ **`RESULT IS NOT GOOD`**.

## 5. Owner-only actions (COORD/owner; no worker route can do these)

1. **Same-camera donor frame — X39 Route A, the only admissible parity route.** The **owner personally** launches `C:\Games\Cossacks 3\cossacks.exe`; the assistant never executes or copies the donor. Pin: `mapsize = 0` → **320×320** (no donor 240² enum), `TerrainTypes 0 Land (`nowater2`)`, season **0 Summer**, explicit `randkey0`/`randkey1` (mark `UNKNOWN` if unreadable — downgrades the comparison), camera from `data\cameras\camera.cfg` (tilt **−32°**, focal **400** Min=Max, dolly/SphereHeight/Length **20…58**, DepthOfView **1200**; record actual zoom), **1280×720 windowed**, no HUD over ROI; saved `.map` + donor PNG **outside the repo** with SHA-256; a ground-only fractional ROI confirmed on **both** frames (sky/HUD/units ⇒ UNVERIFIED, not retried until green); written attestation "donor launched by owner; assistant never executed donor". A donor PNG is **necessary but not sufficient** (X39 §4): same seed keys do not guarantee the same scene while `GenerateMapRandKey`, saved-map key bytes, donor FOV and `;`-corpus activation are `[U]`. `X39_ab_feasibility.md` **is present** — use it; do not claim it is absent.
2. **DLC entitlements / scope decision.** Winter needs `gc_lastknowndlc_dlc2`, desert `gc_lastknowndlc_dlc3`; decide whether season/lake/DLC5 terrain (including rivers, currently `OUT_OF_SCOPE`) is in scope and supply entitlements. Also decide whether to permit a read-only donor runtime/GL trace — otherwise `;`-corpus activation, blend pass count and `hmapTex` binding stay permanently `[U]`.
3. **Free tools (none required to continue; Craft Anything Deep mode stays primary):** **Ghidra 11.x** (second lifter + VMT-pointer discovery for garbled functions / 23 missing anchors); **IDR** — Interactive Delphi Reconstructor (stripped-Delphi class/RTTI recovery); **ImHex** (pattern-language parser + hex view for `.pattern`/`pattern.lib`); **Cutter/radare2** or RetDec (second-opinion decompilation); **HxD** (read-only `.map`/`.pattern` hex inspection).
4. **`git rm --cached` for four tracked large files** (confirmed **tracked** by `git ls-files` at V109; `.gitignore` cannot untrack indexed files — only owner/COORD can):
   - `variant3d/assets/terrain/atlas/tile_index_atlas.png` — 179,912,941 B
   - `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` — 124,463,306 B
   - `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000` — 90,000,000 B
   - `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001` — 89,912,941 B
   
   Then LFS-track or drop them; never commit raw donor material (714/780 derived JSONs embedded the private donor path at V49 — re-verify `C:\Games\Cossacks 3` → `source_rel` normalisation before any commit).

## 6. What would change the verdict

Nothing within the current rules produces a "donor match" — there is no such tier and parity wording is forbidden. The **only conceivable chain** (conditions, not achievements) is **all six**: (1) owner supplies a genuine same-size/seed/type/season/camera/ROI donor GPU frame; (2) an admissible non-blank 1280×720 candidate capture with `script_error_lines=0`, pinned seed/camera/size and identical ROI; (3) inputs matched and labelled (A/B-L1 same keys, or A/B-L2 importer-rendered same geometry) — unmatched seed or unverified ROI degrades to direction-only; (4) fresh gates green, not stale, with 575/582/585 acknowledged and `app/**` byte-identical; (5) spec/toolchain evidence completed — §§01–14 READY, X15 root manifest, I05 atlas/I03 feed, N17 populated and signed, `blocking_unverified = []`; (6) a **demonstrated byte-identical geometry + pixel-identical frame under the proven-matched manifest**, ruled by COORD explicitly. Until **all six** hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"` and `RESULT IS NOT GOOD`. Even if every gate went green, the best honest outcome remains **"gates green / internal consistency PASS / donor parity UNVERIFIED"** — a `compare_shots.py` number, a still or a self-consistent visual score cannot substitute. Default flip to `"donor"` is a separate, deferred ticket.

## 7. Corrections applied to stale claims (re-read, not inherited)

- **Stale "backend inert / uncomposable":** corrected to **default-legacy, opt-in-only, ungated, contract-repaired (V61/V65 static PASS)**, runtime stream `[U]` (V105 C1; V67 D02/D07/D11). Do not say "donor mode is inert".
- **Stale "X39 absent / not landed":** corrected — `reports/X39_ab_feasibility.md` **is present** (V109 `Test-Path` True), supplies the owner capture procedure and 320² enum-0 pin (V105 C2; V67 D06). Do not say "X39 is not landed".
- **Stale "20 keys":** corrected — `globalparams.cfg` has **exactly 19 flat active keys** (`spec/09:11,22`, re-read here; V37/V47-38; X20) **+ 13 local keys**; F03's "20" is an authoring error (V105 C3; V67 D09). Never invent a 20th key.
- **V99 fix note:** no standalone `V99*` fix-note report exists on disk (V109 glob/`Test-Path` False, consistent with V105's "absent at final glob"); no content was invented for it. The corrections above are sourced to **V105 §8 C1–C3** and **V67 §7** and are applied directly here.

---

*End of V109. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md`). Read-only: no source, shader, asset, config, test, result JSON, queue, runner, git index, Godot or donor state changed; no donor binary executed or copied; no gate, capture or benchmark run; no PASS/green/parity claim asserted.*
