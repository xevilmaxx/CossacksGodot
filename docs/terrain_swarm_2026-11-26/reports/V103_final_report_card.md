---
id: V103
ticket: "TERRAIN-SWARM-2026-11-26 / V103 — FINAL REPORT CARD (one page, owner-facing)"
agent: "V103 (read-only final report-card subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V103_final_report_card.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V103_final_report_card.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
parity_status: UNVERIFIED
point_in_time: "V103 dual-pass read 2026-11-26 ~10:27:40 local. Earlier anchors: V87 10:19:46 (151 board ids / 117 reports / 5,255 asset files / 302,411,732 B), X59 (780 assets / 242,102,391 B), V77 (102–123 reports / 780 assets). All counts point-in-time; the set was still moving."
multiple_passes: true
multiple_pass_note: "Headline counts verified by two independent instruments (PowerShell Get-ChildItem/Measure-Object + Python os.walk/getsize) in the same read; the two agreed exactly on every value. Board/reports/assets grew between the V87 10:19:46 snapshot and this 10:27 read; both figures are labelled. No claim promoted on a single reading."
sources_read: "CHARTER.md, README.md, HANDOFF.md, REPORT_INDEX.md, spec/README.md, reports/V57_final_parity_statement.md, reports/V81_owner_decision_packet.md, reports/V87_swarm_statistics.md, reports/V98_credits_final.md, reports/X59_donor_bytes_seal.md; live filesystem + board re-read."
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed by any worker, and no gate result is asserted here. Nothing in this card is a green verdict, a gate PASS, or a donor-match claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# V103 — FINAL REPORT CARD (owner-facing, one page)

> **Mandatory reviewer wording (verbatim):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

**Honest frame.** Presence and byte-decode integrity are **not** correctness, a gate result, spec READY or donor parity. This card carries **no PASS, no green verdict and no parity claim**.

## 1. The numbers — two-command verification, point-in-time

Every headline count was re-globbed by **two independent commands** in one read; values agreed exactly.

| Metric | Count (V103 @ ~10:27) | Two commands (agreement) | Earlier anchor |
|---|---:|---|---|
| Workers launched | **162 board IDs** (union with reports **166**; 4 report ids with no board row) | PowerShell regex on `SWARM_BOARD.md` rows → 162 unique; Python `re.match` → 162 / union 166 | V87: 151 board ids, union 158 @10:19:46 (board grew to 162 by 10:27:09) |
| Reports landed | **127 `.md` files** | `Get-ChildItem -Recurse -Filter *.md \| Measure-Object` = 127; Python `os.walk` endswith `.md` = 127 | V87: 117 @10:19:46; V77: 102–123 (still growing) |
| Donor bytes decoded | Byte-exact closure: `pattern.lib` **30,309,138 B** / 680 sections / 39,780 records; **710/710** `.pattern`, 550,908 `Rec24`, 678/680 min/max; **4,466** mask TGAs; **7** cfg files; `.map` records **102,400/102,400** + **147,456/147,456**; exact LCG; opcode-level stamp/blend. Donor install sealed read-only: **17,237 files / 10,404,789,374 B / 14,546 hashes, 0 identical hashes in repo** (X59) | cited byte counts cross-read in V57 §1 / V81 §2.1 / X27 §2 / X59 §2 (two hashing instruments, 8/8) | unchanged from V87/V98/X59 (these are decode-integrity counts, not a total "whole donor decoded" figure) |
| Implementation files | **13 / 13 present** (6 tools, 5 GDScript, 1 shader, 1 test) | PowerShell `Test-Path` loop = 13/13; board inventory cross-read = 13 | V87: 13 core; + I11 two-file seam and 2 backups (not new files) |
| Derived assets | **5,256 files / 358,196,527 B (~341 MiB)**, untracked, unvalidated (tiers `patterns/`, `masks/`, `atlas/`, `cfg/`) | PowerShell `Measure-Object -Sum Length` = 5,256 / 358,196,527; Python `os.walk`+`getsize` = identical | V87: 5,255 files / 302,411,732 B @10:19:46; V77/X59: 780 files / ~242 MB |
| Temp corpora (outside repo) | **41,310 files / 614,758,996 B (~586 MiB)** — `cossacks3_decomp` 18,919/298,135,470; `editor_decomp` 22,385/315,391,988; `editor_decomp_idx` 6/1,231,538 | PowerShell per-folder `Measure-Object` = 41,310 / 614,758,996; Python sum = identical | V87/X01/X02: 41,310 / 614,758,996 (exact agreement) |

**Discarded-pass honesty:** a board-status parse reuse of `$Matches[1]` once produced false empty ids; it was redone capturing the id first (as V87 did). Counts above are the corrected second read; `reports/`, `assets/` and `SWARM_BOARD.md` all had mtimes within seconds of the snapshot.

## 2. Three tiers — what is verified, what is only self-consistent, what is not

- **DONOR-GROUNDED STRUCTURE VERIFIED (tier 1, donor decode side only).** Byte-exact, independently cross-read: `.pattern` size law `S=8+4wh+54(w−1)(h−1)` 710/710 with zero residual (independent 13/13 corrected-grid pass); `pattern.lib` 680-section plaintext index; 4,466 terrainmask TGAs with `h=−1.1·B/255`; 7 hashed cfg files; exact 32-bit LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²` with 11+3 reseeds; three-path relief stamp in `sub_755f30` (`Min` pivot, `Max` unused); `bmTransparency = glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`; 37-byte `.map` records; 124 tile ids/season. This is **decode integrity only** — not a signed tier-1 port verdict (no port-side byte match, no D3 dump integrity). `[O]/[D]`
- **SELF-CONSISTENT VISUAL (tier 2, `PORT APPROXIMATION`) — criteria drafted, result unobserved.** Per-class properties exist (silhouette ≥centre +4 m / footprint +2 m, props ON/OFF, continuous beach→foam→water with ids 93/97/98, deposit mesh on a centred disc, organic wet patch with no water plane, no concentric rings / diagonal vein lattice). No admissible 1280×720 windowed capture, no pinned camera/seed/size, no frozen 240²/320² baseline, no `inbox/qa/captures/**` — only PENDING markers. Every visual statement stays `PORT APPROXIMATION`. `[D]/[I]`
- **UNVERIFIED (tier 3, large and categorical).** Mountains, sea, rivers, swamps, iron/coal mines have no reliable donor still (12 third-party images are direction-only; "highlands" is a two-pass-confirmed false positive). 4,265/18,918 (22.54%) `cossacks.exe` and 12,254/22,384 (54.7%) `editor.exe` discovered functions garbled; 23/34 D01 anchors absent; packed `.bind` (entropy 7.96) never unpacked; all 972 `.inc` excerpts `;`-prefixed intent with no donor execution; blend pass count unresolved after six passes; row-sign flip, `hmapTex` bind, x87 precision, native kernels and `.pattern`/`.map` field semantics remain `[U]`. No tier above 2 exists; tier 2 never implies tier 1. `[U]`

## 3. The one-sentence answer — "is terrain cloned?"

> **No — terrain is not cloned: the donor's terrain-relevant data formats and a small set of named functions are byte-exactly decoded and a donor-shaped port scaffold exists, but no donor GPU A/B frame, no gate result and no runtime observation exist, so the honest verdict is `PORT APPROXIMATION` with donor parity `UNVERIFIED`.** `[D]/[U]` (verbatim from V57 §4, reaffirmed by V81 §1)

## 4. Gate and parity status — honest, ungated

- **No gate was run for today's tree.** All result JSONs are stale (2026-11-25); `assert_clean` was `DIRTY` with **575/582/585 unacked**; no fresh 240²/320² baseline; A24 relief-props atom a hard FAIL at the earlier snapshot. V61/V65's "static PASS" is a **line-level type/arity/contract reading only** — no parse job, runner, gate or capture was executed by those workers. Every `HANDOFF §4` cell remains `TODO(COORD)`.
- **No capture and no donor GPU A/B frame.** `inbox/qa/**` holds PENDING placeholders only; no admissible candidate capture, no donor frame, no reviewer sign-off.
- **Default legacy, ungated.** `terrain_backend` defaults to `"legacy"` (`main.gd:125`, `world3d.gd:144`; config key `features.terrain.backend`); only the exact `"donor"` opts in; late switching refused after `bind()`. No default flip; no green claim.
- **Parity:** `parity.status = "UNVERIFIED"`, `parity.claim = NONE`; no tier above 2; `blocking_unverified` non-empty ⇒ conservative owner reading `RESULT IS NOT GOOD`. V63/V76 record **NO-GO** on six/five blockers. Nothing here upgrades any class.

## 5. Licence / compliance status

- **CREDITS appended (done).** V49's paste-ready block is present and byte-identical at `variant3d/CREDITS.md:136-165`; `app/CREDITS.md` untouched (98 lines, 0 V49 hits). No duplicate paste needed (V98 §1).
- **`.gitignore` rules landed (done).** `V78 / V49 compliance` block at `.gitignore:132-154` covers four legacy paths (`:137-140`) plus future `terrain_new/**` atlas/split outputs (`:141-142`) and raw-donor extensions; `git check-ignore --no-index -v` resolved every path (V98 §2).
- **Donor-bytes seal clean.** X59 hashed 906 new/untracked files + 20 others + 5 modified tracked + 4 large derived files against 17,237 donor files (10.4 GB): **0 identical hashes**; no raw donor binary copied; all 780 derived JSONs carry `visual_parity_claim:false`; `app/**` byte-untouched.
- **Open owner git action.** Four legacy large derived files are **still TRACKED** and have no ignore rule: `terrain/atlas/tile_index_atlas.png` (179,912,941 B), `..._winter.png` (124,463,306 B), `atlas_parts/tile_index_atlas.part000` (90,000,000 B), `...part001` (89,912,941 B). Ignore rules cannot untrack indexed files — only the owner/COORD can `git rm --cached` / LFS-track them (V98 §2.3, X59 §5). Also re-verify the `C:\Games\Cossacks 3` → `$COSSACKS3_DIR`/`source_rel` normalisation in derived JSON before any commit (V49 finding; 714/780 embedded the private path at V49, inheritance not re-counted by V98).

## 6. What only the owner can do

1. **X39 Route A donor A/B capture — the parity ceiling.** The owner personally launches `C:\Games\Cossacks 3\cossacks.exe` and captures a matched frame (assistant never executes/copies donor): size `mapsize=0 → 320×320`, TerrainTypes 0 Land (`nowater2`), season 0 Summer, explicit `randkey0`/`randkey1`, camera from `data\cameras\camera.cfg` (tilt −32°, focal 400, dolly 20…58, DoV 1200), 1280×720 windowed, saved `.map`+PNG outside repo with SHA-256, ground-only ROI on both frames, written attestation. A donor PNG is **necessary but not sufficient**; parity requires a demonstrated match.
2. **DLC entitlements / scope decision.** Winter needs `gc_lastknowndlc_dlc2`, desert `gc_lastknowndlc_dlc3`; decide whether season/lake/DLC5 terrain (incl. rivers, currently `OUT_OF_SCOPE`) is in scope and supply entitlements.
3. **Decision on a permitted read-only donor runtime / GL trace** — otherwise `;`-corpus activation, blend pass count and `hmapTex` binding stay permanently `[U]`.
4. **Bookkeeping sign-off** (`declared_unverified`/`blocking_unverified` split; 240² vs 320² canonical capture size; VMT re-lift funding) and the four tracked-large-file git decision in §5.

---

*End of V103. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V103_final_report_card.md`). Read-only: no source, shader, asset, config, CREDITS, `.gitignore`, test, result JSON, git index, runner or Godot state changed; no gate run; no donor binary executed or copied; no capture or parity metric invented. All counts point-in-time via two independent commands; re-glob before use. No PASS, green or donor-parity claim asserted anywhere.*
