---
id: DEC-U-PEACE-DEEP
worker: DEC-U-PEACE-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Binary was read as bytes for string search only (no disassembly, no execution). Donor DScript text read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All captures below are owner-authorised procedures, not worker runs."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-PEACE-DEEP — packed CODE peace-name search, `>` wrapper/gametime source, equality-boundary opcode status, expiry first-transition guard vs victory precedence (2026-11-26)

Prior pinned context: peace index→seconds table [O] (`misc.script:4262-4281`, ×60 at `:4281`); strict `gametime > gfloat_peacetime` expiry (`nothing.inc:658-695`); port gate `time_s < PEACE_TIME` labelled PORT APPROXIMATION [U] for identity/equality boundary (`variant3d/scripts/game.gd:8985`, `DEC_U_menu_peace.md` §7 F-GATE). This ticket attacks from NEW angles only; it re-pins but does not re-prove those reads.

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass (NEW this ticket) | Result / evidence |
|---|---|---|
| P1 | Pin re-assert (read-only) | `C:\Games\Cossacks 3\cossacks.exe` Length 5,768,048 B, SHA256 `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C` — matches `DEC-U-MENU-PEACE` §0-P1. No execution, copy, or target-open. |
| P2 | PE section map (read-only, for VA math) | `e_lfanew=0x100`, 10 sections; `CODE: VA 0x1000 rawsz 0x4F0E00 rawptr 0x400`; imagebase `0x400000` (§1, EV-PE). |
| P3 | Packed CODE byte search, case-sensitive (a) | `gfloat_peacetime 0`, `gbool_peacemode 0`, `peacetime 0`, `PeaceTime 0`, `peacemode 0`, `ReadPeaceTime 0`, `gbool_editor_peacemode 0` hits; `GetGameTime 1 @ file 0x29EEF6` (§1, EV-BIN1). |
| P4 | Packed search, case-insensitive (a) | `peacetime 0`, `peacemode 0`, `peace 0`, `victorystate 0`, `CheckEndGame 0`, `FreeList 0`, `BorderObjects 0`, `GetPeaceTime 0` (§1, EV-BIN2). Single `gfloat` hit @ `0x2E3C76` is `QueryMachineResultSetTagFloat`, NOT peace (§1, EV-BIN3). |
| P5 | Native time-API table context (b) | `GetGameTime` sits in a CODE-embedded DScript native-signature table beside `GetCurrentTime / GetTotalTime / SetGameTime / GetRealTime` with VAs (§2, EV-TBL). |
| P6 | Gametime-source + `>` wrapper read (b) | `nothing.inc:72` `var gametime : Float = GetGameTime;` [O]; `>` at `:658` is DScript script-text float compare — no named native wrapper exists (§2). |
| P7 | Equality-boundary opcode status (c) | NO opcode decoded: no disassembly performed, no Jcc/JA/JBE bytes claimed. Boundary stays script-text [D]; port identity/equality stays [U] (§3). |
| P8 | Expiry guard vs victory precedence (d) | Expiry `:658-660` latch = `gbool_peacemode` flag itself; no `bPrevExists`/`<> win`/`=0` guard; `_misc_CheckEndGame :647` runs BEFORE expiry `:658`; expiry writes zero `victorystate` (§4). |
| P9 | Net peace paths re-read (d) | `readpeacetime.inc:1-36` + `writepeacetime.inc:1-39`: transport-only `RecordCustom` boolean `bstate`, rating-gated country fixups (§4, EV-NET). |
| P10 | Port gate re-pin (no edit) | `variant3d/scripts/game.gd:8955-8986` `_check_victory` — CheckEndGame-then-peace-gate order landed; boundary comments already labelled PORT APPROXIMATION [U] (§5, EV-PORT). |

## 1. Packed CODE byte search for peace API/property names [O-absence + one positive]

Method [D]: whole-binary raw byte search (`py`, read-only, no execution), exact ASCII substrings then case-insensitive pass. File→RVA→VA math: `RVA = 0x1000 + (fileoff − 0x400)` for `fileoff` inside CODE (`rawptr 0x400`, `rawsz 0x4F0E00`); `VA = 0x400000 + RVA` (EV-PE).

### 1.1 Case-sensitive counts (EV-BIN1) [O]

| Needle | Hits | Location |
|---|---|---|
| `gfloat_peacetime` | **0** | — |
| `gbool_peacemode` | **0** | — |
| `peacetime` | **0** | — |
| `PeaceTime` | **0** | — |
| `peacemode` | **0** | — |
| `ReadPeaceTime` | **0** | — |
| `gbool_editor_peacemode` | **0** | — |
| `GetGameTime` | **1** | file `0x29EEF6` → RVA `0x29FAF6` → **VA `0x0069FAF6`** (substring start; full signature string starts `0x29EEED` → VA `0x0069FAED`, §2) |
| `WritePeaceTime` | **0** | — |

### 1.2 Case-insensitive counts (EV-BIN2) [O]

`peacetime 0`, `peacemode 0`, `peace 0`, `victorystate 0`, `CheckEndGame 0`, `FreeList 0`, `BorderObjects 0`, `GetPeaceTime 0`. No lower/upper-case variant of any peace/victory API name is CODE-embedded.

### 1.3 The lone `gfloat` hit is NOT peace (EV-BIN3) [O]

File `0x2E3C76` context: `…QueryMachineResultGetTagFloat… | …procedure QueryMachineResultSetTagFloat(const resulthandle : Integer; const tagfloat : Float)…`. The substring is `…SetTagFloat`, a query-machine API — unrelated to `gfloat_peacetime`. Likewise the `0x2806C5 GameTime` hit is `LanPublicServerProfLastGameTime`, not the sim clock.

### 1.4 Reading [D]

Unlike the blend/tick CODE-embedded tables, there is **no CODE-embedded table entry for any peace name**: no `gfloat_peacetime`, `gbool_peacemode`, `peacetime`, `PeaceTime`, `Read/WritePeaceTime`, or `GetPeaceTime` string exists in the binary at any casing. Peace globals live at the DScript layer only — declared `dmscript.global:2298-2299` (`gfloat_peacetime = Float`, `gbool_peacemode = Boolean`) [O], initialised `dogenerate.inc:2059-2060` [O], expired `nothing.inc:658-695` [O]. The absence is load-bearing: nothing in (a) contradicts or extends the script-text chain, and no VA can be cited for a peace property.

## 2. Native wrapper for the strict-`>` comparison and the gametime source [O/D]

### 2.1 Gametime source is byte-proven (EV-TBL) [O]

`GetGameTime` is a CODE-embedded DScript native-signature-table entry. Neighbourhood (file offsets, `0x29EExx`, contiguous table with `FF FF FF FF + len` framing exactly as in blend/tick tables):

```
… function GetCurrentTime(): Float … function GetTotalTime(): Float …
… function GetGameTime(): Float … procedure SetGameTime(val: Float) …
… function GetRealTime(): Float …
```

VAs (string starts, `0x400000`-based): `GetCurrentTime 0x0069FA99`, `GetTotalTime 0x0069FAC5`, **`GetGameTime 0x0069FAED`** (substring `GetGameTime` at `0x0069FAF6`), `SetGameTime 0x0069FB14`, `GetRealTime 0x0069FB41`. The per-tick source is `nothing.inc:72`: `var gametime : Float = GetGameTime;` [O] — a fresh native call each global tick, then `deltatime := gametime − lastprogresstime` (`:73`) and the pause gate `:75`.

### 2.2 No native wrapper exists for the strict-`>` comparison [D]

Repo-wide DScript grep for a named greater-than/float-compare native wrapping `:658` finds nothing: the `>` in `if (gbool_peacemode) and (gametime > gfloat_peacetime) and …` (`nothing.inc:658`) [O] is a DScript-engine float comparison, not a callable API-table entry. There is no `FloatGreater`, `CompareGameTime`, or peace-comparator string in the binary (§1 gives zero hits for every candidate name, including case-insensitive). Consequence: the boundary operator is proven **only** at the script-text layer (strict `>`, i.e. at exact equality peace still holds [D, forced by the literal]), and there is no wrapper VA to cite, decode, or port.

## 3. Equality-boundary tick: opcode status — NOT decoded, stays [U] for the tick

Claim discipline: this worker performed string search + PE section math only. **No instruction decode was performed**: no bytes around any compare site were disassembled, no `JA/JBE/UCOMISS` opcode is cited, and none is claimed. Therefore:

- Script-text boundary [D, unchanged]: donor expires iff `gametime > gfloat_peacetime` (`nothing.inc:658`); at `gametime == gfloat_peacetime` the `if` is false and peace still holds — a literal reading, not an opcode reading.
- Whether the **equality tick triggers expiry** (i.e. the exact float-compare codegen, NaN/epsilon behaviour, and which tick index first observes `>`) is **NOT byte-proven** and stays **[U]**.
- Port gate `if Data.PEACE_TIME > 0.0 and time_s < Data.PEACE_TIME: return` (`variant3d/scripts/game.gd:8985`) [O] remains labelled PORT APPROXIMATION [U] for both the time-base identity (`time_s == gametime`) and the exact-equality tick, exactly as its comments at `:8974-8984` already state. No behaviour, value, comment, or save-key change is specified by this ticket.

No invented boundary; no parity claim.

## 4. First-transition guard on peacetime expiry vs victory stamp precedence [O/D]

### 4.1 Expiry has no victory-style first-transition guard [O]

`nothing.inc:658-660` verbatim shape: `if (gbool_peacemode) and (gametime > gfloat_peacetime) and (not _net_IsReplay) and (not _net_IsClient) then begin gbool_peacemode := false; …`. The ONLY latch is the flag itself: after the first expiry tick sets it `false`, the `:658` conjunction can never re-fire. There is no `bPrevExists` edge (cf. W1 defeat `progress.inc:128`), no `<> win` per-survivor skip (cf. W5 `miscext2.script:3810-3818`), and no `if (=0)` first-write-wins time gate (cf. every guarded victory stamp, `DEC-U-ENDGAME-STAMP` §3). `ReadPeaceTime` (`readpeacetime.inc:23-24`) uses `if (gbool_peacemode<>bstate)` as a change detector for the net echo only — not an expiry guard.

### 4.2 Ordering vs victory stamps [O/D]

- `_misc_CheckEndGame;` at `:647` runs **UNGATED every global tick, BEFORE** the expiry block at `:658` [O]. The team-win law (W5) therefore reads the fresh per-player `bexists` and can stamp `win` on the SAME tick that peace later expires.
- The expiry path (`:660-693`) writes **zero** `victorystate / victorystategametime` fields (full-file grep: `nothing.inc` contains no `victorystate` write [O-absence, re-pinned from `DEC-U-ENDGAME-STAMP` §1]). Expiry destroys `ptborder` objects, broadcasts `WriteFreeList` + `WritePeaceTime` with `fbstate := gbool_peacemode` (`:681-685`), issues `GameObjectRequestToDestroyByHandle` (`:689`), and clears/refreshes minimap primitives (`:691-692`) — never a stamp.
- Precedence consequence [D]: a kill and a peace-expiry coinciding on tick T yields `lose` (W1, staggered slice) → `win` (W5 at `:647`) → peace cleared (`:658+`) in that frame order; `win_tick >= lose_tick` stays legal and peace-clear never overwrites either stamp. The port's `_check_victory` order (CheckEndGame first, peace gate after, `game.gd:8960-8986`) already mirrors this precedence — noted, not changed.

### 4.3 Net peace paths are transport, not guards [O]

`WritePeaceTime` (`writepeacetime.inc:6-34`) packages `arg_plr.fbstate` via `RecordCustomBegin('ReadPeaceTime') + RecordCustomWriteBoolean + RecordCustomEnd` under `_net_IsOnline or _net_IsRecord` only; `ReadPeaceTime` applies it under `_net_IsOnline` with rating-gated country fixups (`readpeacetime.inc:10-21`). Neither path conditions the `:658` sim expiry. Excluded from the 1:1 contract, cited only as the boundary.

## 5. Port disposition — read-only inspection, NO edits made

- `variant3d/scripts/game.gd:8955-8986` (`_check_victory`) already encodes: CheckEndGame ALWAYS before the peace gate (`:8960`, citing `nothing.inc:646`), scenario-suppression, then the `PEACE_TIME` gate at `:8985` with the strict-`>` boundary + PORT APPROXIMATION labels (`:8974-8984`, citing `DEC_U_menu_peace.md` §4 and `nothing.inc:658`). Behaviour is existing port policy; this ticket specifies NO change to it.
- `app/scripts/game.gd:5467` carries the same `Data.PEACE_TIME > 0.0 and time_s < Data.PEACE_TIME` gate (per `DEC-U-MENU-PEACE` §7); likewise unchanged.
- Donor-faithful seconds sourcing (`dogenerate.inc:2059` + `misc.script:4281` ×60) and the `main.gd`/`config.gd` 60× conversion remain owned by `DEC-U-MENU-PEACE` §7 M1/C1 — not re-specified here.

## 6. Still-[U] register — fixed-seed peace-expiry captures, zero-mismatch termination

Rules: every capture runs on a FIXED seed / fixed lobby preset, is performed by the OWNER (donor binary never run by a worker), and passes only on ZERO mismatch across 3 identical runs. No boundary tick, no VA, and no parity is asserted without the cited capture.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) + zero-mismatch criterion |
|---|---|---|---|
| U-E1 | CODE-embedded peace-name absence | Zero hits at every casing for 8 peace needles (§1) via one read-only scan [O-absence] | Re-run the §1 needle list on the pinned hash (`t_87f0f3c130b0`, size check first) with an independent scanner. **Zero-mismatch:** identical 8× zero counts + the §1.3 `gfloat→TagFloat` non-peace classification; 3 runs byte-identical. Any new hit ⇒ §1 revised, never silently adopted. |
| U-E2 | `GetGameTime` native VA + per-tick source | Table entry VA `0x0069FAED` + `:72` call [O] from one worker scan | Owner re-scan of the §2 signature neighbourhood on fixed binary; dump the 5 time-API VAs. **Zero-mismatch:** exact VA set `…FA99/FAC5/FAED/FB14/FB41`; 3 runs identical. No wrapper beyond the table is claimed. |
| U-E3 | No comparator wrapper | Zero candidate comparator names in binary + script-text `>` only [D] | Grep DScript for any float-compare native + re-scan binary for `Greater/Compare/UCOMISS`-family names. **Zero-mismatch:** still zero wrapper hits across 3 runs; the `:658` literal stays the sole boundary source. |
| U-E4 | Equality-boundary tick (opcode deliberately undecoded) | Script-text strict-`>` [D]; tick behaviour [U] (§3) | Seed S, peace index 1 (600 s): log `gbool_peacemode + gametime` per tick across the boundary + ptborder count + minimap-primitive state. **Zero-mismatch:** last `true` tick has `gametime <= 600.0`, first `false` tick has `gametime > 600.0`; border count → 0 exactly on the `false` tick; 3 runs identical tick indices. Until then, no equality-tick claim. |
| U-E5 | Port identity `time_s == gametime` | Labelled PORT APPROXIMATION [U] (`game.gd:8978`) | Headless: fixed seed, drive `time_s` 599→601 with `PEACE_TIME=600.0` across `_check_victory`. **Zero-mismatch:** guard returns (no award) at 599 and 600, passes at 601; 3 runs identical. Donor-tick equivalence still NOT claimed. |
| U-E6 | Expiry latch vs victory-guard shapes | Latch = flag itself; no `bPrevExists/<> win/=0` on expiry [O] (§4.1) | Seed S 1v1 with peace index 1: force a last-unit kill on the SAME tick peace would expire; log W1 `lose_tick`, W5 `win_tick`, peace-clear tick, all three `gametime` values. **Zero-mismatch:** `win_tick >= lose_tick`, peace-clear tick `>= win_tick`, all stamps keep first-write-wins times; 3 runs identical. Any stamp overwrite by expiry = fail. |
| U-E7 | Stamp-then-expiry frame order | `:647` before `:658` [O] (§4.2) | Seed S 2v2: wipe team B exactly at the expiry tick; log per-tick `victorystate_int` + `gbool_peacemode`. **Zero-mismatch:** survivors read `win` from the `:647` pass before/independent of the `:658` clear; expiry never flips a stamp field; 3 runs identical. |
| U-E8 | Net-path non-interference | `Read/WritePeaceTime` transport-only [O] (§4.3) | Offline seed S + online-mirror harness (owner only): assert `:658` expiry tick identical with net paths stubbed vs live. **Zero-mismatch:** same expiry tick ±0; 3 runs identical per harness. No net value is ported. |

Forbidden: inventing any Jcc/opcode, any peace VA, any equality-tick number, any score/time-limit threshold, any per-mission trigger→victory mapping, any LAN score/rating value, any camera constant.

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items rest on donor TEXT `[O]` with `file:line` plus read-only byte counts with file offsets/VAs (§1-§2, §4); open items name exact captures in §6.
- No number invented: no opcode, no peace VA (absence reported, not a value), no equality tick, no `40/50` rows, no threshold beyond cited literals. Every added port line must carry `file:line` + `[O]/[U]`; `visual_parity_claim=false`.
- Read-only compliance: exactly one repo file written (this report). The two helper scripts under `%TEMP%\opencode` (binary string scans) live outside the repo and change no repo state. Donor evidence is text reads + byte-count scans; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: `WritePeaceTime/WriteFreeList` broadcasts, `_net_IsReplay/_net_IsClient/_net_IsOnline` branches, and rating/country fixups are cited only as exclusion boundaries, never as sim law.

*End of DEC-U-PEACE-DEEP.*
