---
id: DEC-U-AUDIO-RNG
worker: DEC-U-AUDIO-RNG (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4E72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only (Python/Grep reads). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker; no port capture produced."
context: "PORT1TO1_determinism_audit.md Class N4 flags variant3d/scripts/audio.gd:360 (`names[randi() % names.size()]`) and :368 (`randf_range(0.92,1.08)`) as unseeded global-RNG replay hazards. This ticket recovers statically whether the donor sound system has its own sound-selection/pitch/pan RNG, which stream/seed it uses, its call sites, and proves it does not touch sim state."
labels: "[O] verbatim donor literal (path:line) · [D] deterministic reading · [I] inference · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-AUDIO-RNG — donor sound RNG recovery: clip pick / pitch / pan, stream, sim-effect (2026-11-26)

## 0. Pass ledger (owner rule; every native claim pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = craft.json donor target `C:\Games\Cossacks 3`, 5,768,048 B, sha `87f0f3c1…4e16c` (matches DEC-U-RNG-LEDGER §0, DEC-U-SKIRMISH §0). No binary opened/executed/copied by this worker. |
| P2 | Fresh read `data/scripts/lib/sound.script` (586 lines, full file) | Live registrations `:109-231`; dead `{…}` block `:234-383` (agrees DAUDIO-01 §2.1); clip-pick RNG at `:396`, `:446`, `:501`; `SetSndSoundRandomOffset(0,…)` only at `:476`, `:523`; no pitch/frequency call anywhere in file. All `[O]` §1. |
| P3 | Fresh read `data/scripts/lib/gui.script` sound region + `misc.script:484-498` | Duplicate `_sound_EmitterPlaySound` at `gui.script:2958-3004` (pick at `:2966`); `_sound_EmitterPlayWalkSound` at `:2744-…` (pick at `:2752`, deterministic override at `:2757-2758`); `RandomInt := floor(random*32768)` at `misc.script:494-497` proves lowercase `random` = Delphi stream. All `[O]` §1. |
| P4 | Fresh read `progress.inc/soundcontrol.inc` + `soundcontrolcounters.inc` (both fully commented `[*] = ;` except counters path) | `soundcontrol.inc:29-75` dead copy of emitter-pick (`:37` same formula, commented out); live walk-counter path `soundcontrolcounters.inc:10-62` (pick `:18`, **overridden** by round-robin `:23-24`); consume loop `:98-195` has NO RNG. `[O]` §1. |
| P5 | Absence greps (donor text, read-only) | `RandomOffset` hits = exactly 2 (`sound.script:476,523`, both literal `0`) — §1-F4. `pitch`/`Pitch`/`SetSndSoundFrequency` = 0 hits in `lib/*.script`. `snd*.inc` files = none exist; `manager.lib` for sound = none exists (only `data/pfx/manager.lib`, particle domain); sound config is `data/sounds/manager.cfg` (no RNG keys — DAUDIO-01 §4.1 `[O]`). `RandomExt` in `sound.script`/`gui.script` sound funcs = 0 hits (only `gui.script:1044,1268` combobox cosmetic). `[O]` §1. |
| P6 | Native mixer reuse (no new binary pass by this worker) | Re-cite DAUDIO-01 §4.5 byte finders on `t_87f0f3c130b0`: `SndGetOrCreateSound` ×1 @`0x2b944a`, `SetSndSoundRadius[es]` ×2 @`0x2b99ca/0x2b9a5a`, `SndGetOrCreateAmbientThread` ×1 @`0x2b8986`, `SetUseSoundManagerListenerAsObject` ×1 @`0x2b9fd6`, `waveOutOpen`/`PlaySoundA` ×1/×1 @`0x5000e8/0x500106`; clip/bank names 0 hits (external data). RTTI `TOSWSoundSource` fields incl. `RandomOffset` (DEEPDEC_07 §5 `[O]`). No native sound-RNG draw recovered — stays `[U]` §4-U-AUD-3. |
| P7 | Port read-only inspection (EV-PORT) | `variant3d/scripts/audio.gd:360,368` (N4 draws); `:334-337` wall-clock dedup; `:150-253` ambient `_process` (reads only); `main.gd:1770-1820` `_play` fan-out (all call sites consume `game.events`, none feed back); `audio.gd:466-477` `selection_clip` (deterministic, no RNG). No edit. |
| P8 | Stream-identity cross-check | RNG-LEDGER §1 (`misc.script:493-498` + `dmscript.global:176` `gc_c1rand_to_random=32768`) + §2 (Delphi `d←d×0x8088405+1`, seeder `0x4033b8` = QPC-low else TickCount, 3 static callers, free-run — `ev_6478320b…`/`ev_78bcf9c8…`/`ev_583b7258…` GEN-SEED §1 `[O]`) ⇒ donor sound `random` = **G (Delphi) stream**, NOT S (`RandomExt`) stream. `SetRandomKey` reseeds never appear on any sound path (P5 grep). `[D]` §2. |

DSL note `[D]`: donor `{...}` = comment; `//` = comment; uncommented head is live value (RNG-LEDGER §0).

---

## 1. Evidence register (new reads this ticket carry `path:line`; binary claims re-cite prior ids)

| Evidence id / source | Label | Observation / supports |
|---|---|---|
| `sound.script:396` `rndind := floor(random*(maxind+1))` (`_sound_EmitterPlaySound`) | [O] | Clip-pick RNG #1. Guarded `if (maxind>0)`; followed by linear probe `:398-430` for first non-playing handle. Lowercase `random` = Delphi G per P3/P8. |
| `sound.script:446` same formula (`_sound_EmitterFadeSound`) | [O] | Clip-pick RNG #2 (ambient fade path). Same guard, same probe `:448-486`. |
| `sound.script:501` same formula (`_sound_PlaySound`, UI/global path) | [O] | Clip-pick RNG #3. Same guard, probe `:503-529`. |
| `sound.script:476` + `:523` `SetSndSoundRandomOffset(0, sndHnd)` | [O] | The ONLY two RandomOffset writes in all donor scripts (P5). Both literal `0`. Fade path `:476` + non-positional path `:523`. Emitter-play path (`:388-434`) sets no offset at all. |
| `sound.script:425` `SetSndSoundRadius({40}8000, sndHnd)` + comment "80 - for 3D sound, 8000 for isometric sound" | [O] | No pan RNG: radius is a fixed literal. Same at `:477` (`8000`), `:524-525` (`8000` + `MaxRadius(0)`). Positional path radius `loudness*1.25` at `gui.script:2990` is arithmetic, not a draw. |
| `gui.script:2966` (dup `_sound_EmitterPlaySound`) + `gui.script:2752` (`_sound_EmitterPlayWalkSound` pick) | [O] | Same G-stream formula in the two gui copies. |
| `gui.script:2757-2758` `rndind := gint_soundsteptick mod (maxind+1); gint_soundsteptick+1` + `soundcontrolcounters.inc:23-24` identical | [O] | Deterministic round-robin OVERRIDE kills the `:2752`/`:18` random pick on the walk path (unconditional assignment after the `if`). Walk clips are counter-sequenced, not RNG-sequenced. Init value of `gint_soundsteptick` not recovered → [U]-AUD-2. |
| `misc.script:494-497` `_misc_RandomInt := floor(random*gc_c1rand_to_random)` + `dmscript.global:176` `=32768` | [O] | Proves lowercase `random` is the Delphi `Random()` builtin (RNG-LEDGER §1 `[O]`). No `RandomExt` on any sound line (P5). |
| `sound.script:534-544` `_sound_RequestPlaySound` | [O] | Request path has NO RNG: grid-index resolve + `sndrequests[sndlibind]+1` + `bsndrequestexist := True`. |
| `sound.script:546-584` music crossfade; `doambientsound.inc` (DAUDIO-01 §3.5 `[O]`) | [O] | No RNG: fixed fade times `3`/`5`, ambient `fadetime 0.3` (`dmscript.global:1233`), loop tags `-1/-2/-3` (`:1234-1236`). |
| `soundcontrol.inc:164-293` consume/merge/play grid loop | [O] | No RNG in the consumer: distance discard `dst > maxdst+lheight+loudness` (`:188`), ±8-cell merge (`:192-226`), group substitution by count thresholds (`:254-262`), then `_sound_EmitterPlaySound` (the §1 pick). |
| `units.snd`/`interface.snd`/`ambient.snd` `Def*` templates (`units.snd:2-16`, `interface.snd:2-16`, `ambient.snd:2-17`) | [O] | `DefRandomOffset=0`, `DefFrequency=-1/0`, `DefNbLoops=1` — defaults are zero/fixed (DAUDIO-01 §4.2 `[O]`, re-observed P5). No per-clip random pitch/pan field varies. |
| `data/sounds/manager.cfg:2-10` | [O] | `MaxChannels=48, OutputFrequency=44100, UpdateFrequency=60, DistanceFactor/RollOffFactor/DopplerFactor=1, HeightFactor=0.0, ScaleFactor=0.02`. No RNG/seed key (DAUDIO-01 §4.1 `[O]`). |
| `cossacks.exe` finders `0x2b944a/0x2b99ca/0x2b9a5a/0x2b8986/0x2b9fd6/0x5000e8/0x500106` (DAUDIO-01 §4.5, re-cited, no new pass) | [O] (prior) | Only API vocabulary in EXE; clip/bank/`gc_snd_ind`/`TSoundGrid` strings 0 hits ASCII+UTF-16. Mixer imports `waveOut*` + `PlaySoundA` (software mixing). |
| `variant3d/scripts/audio.gd:360` `names[randi() % names.size()]`; `:368` `p.pitch_scale = randf_range(0.92, 1.08)`; `:334-337` dedup `Time.get_ticks_msec()/1000.0 < 0.09` | [O] (EV-PORT) | The N4 hazard. Global Godot RNG, never seeded; no `seed()`/`randomize()` site covers it (determinism audit §6 full-tree census). |
| `variant3d/scripts/main.gd:671-674` `can_play = not is_headless`; `:1770-1820` event fan-out; `:1818-1820` `_play` guard | [O] (EV-PORT) | Audio is a one-way sink: `game.events` → `_play` → `audio.play`. No audio return value is read back into sim state anywhere in `scripts/` (verified by P7 grep: only `audio.play`, `selection_clip`, `building_sound`, `work_sound`, `walk_sound` call sites). |
| `variant3d/scripts/audio.gd:466-477` `selection_clip` (`maxi(count,1)-1 % 6 + 1`) | [O] (EV-PORT) | Deterministic already — no RNG. Donor used random-start probe (DAUDIO-01 §4.3); port deliberately differs (D05-selection PORT APPROX, accepted). |

Absent (static non-proof of use, P5): no `snd*.inc` file exists anywhere under `data/scripts` (only `soundcontrol{,counters}.inc`, which are progress files, not bank manifests); no `manager.lib`/`sound*.lib` for audio (only `data/pfx/manager.lib` = particle domain); no `SetSndSoundFrequency`/pitch API call in any script; no `RandomExt` on any sound path; no `Randomize`/`RandSeed`/`SetRandomKey` on any sound path.

---

## 2. Findings — stream, seed, call sites, sim-effect

**F1 [D] — Donor clip-selection RNG EXISTS, and it is the Delphi G stream, unseeded per-event.**
Three live sites share the identical draw `floor(random*(maxind+1))` with `maxind = count-1` (`sound.script:396,446,501`; duplicates `gui.script:2966,2752`). Lowercase `random` is the Delphi `Random()` builtin (`misc.script:497` `[O]`), i.e. RNG-LEDGER stream **G**: LCG `d←d×0x8088405+1`, seeded ONCE at process start from QPC-low-dword else `GetTickCount` (`0x4033b8`, GEN-SEED §1 `[O]`), free-running, never reseeded by any `SetRandomKey`/`SetRandomExtKey64` (no such call on any sound path — P5). It is therefore process-start/wall-clock dependent AND shared with all other G consumers (famine/rebellion rolls, AI die rolls, headshot gate, capture jitter — RNG-LEDGER §4), but it is NOT the sim `RandomExt` (S) stream: no sound line reads `RandomExt`, and no sim line reads the sound `rndind`. Seed provenance: native-only, no script seed literal — never invent one (§4-U-AUD-1).

**F2 [O] — Donor pitch RNG does NOT exist.** Both `SetSndSoundRandomOffset` writes pass literal `0` (`:476,:523`); all `.snd` templates declare `DefRandomOffset=0`; no frequency/pitch setter is called from any script (P5 zero-hit). `sndfreq` (`cFreqFull/High/Medium/Low = 0/0/1/2`, `sound.script:104-107`) is a throttling bucket consumed by `bfreqok[]` gates (`soundcontrol.inc:147-159,185,243`), not a pitch draw. The port's `randf_range(0.92,1.08)` (`audio.gd:368`) is therefore a port INVENTION with no donor counterpart (agrees DAUDIO-01 §5 verdict, now anchored to fresh line reads).

**F3 [O] — Donor pan/volume RNG does NOT exist.** Radii are fixed literals (`8000` isometric global; `loudness*1.25` ∈ {25,50,75,100} positional — `sound.script:425`, `gui.script:2990` `[O]`); ambient volumes are distance ramps with fixed constants (wind `0.2`, town `20..60 m`, sea `±4-cell/200-divisor` — DAUDIO-01 §3.5 `[O]`); no draw feeds any of them.

**F4 [O] — Walk sounds are deterministic round-robin, not RNG.** `gint_soundsteptick mod (maxind+1)` unconditionally overwrites the random pick on the walk path (`gui.script:2757-2758`, `soundcontrolcounters.inc:23-24`). Only the counter's initial value is unrecovered ([U]-AUD-2).

**F5 [D] — Donor sound RNG CANNOT affect sim state (must NOT, and does not).** Verified statically, all `[O]` sites: the three pick functions return only a `sndtag` integer and perform only `Snd*` handle writes (`SndGetOrCreateSound`, `SetSndSoundSourceName`, `SetSndSoundRadius[es]`, `SetSndSoundPlaying`, fade/loop setters) plus debug-counter increments (`gint_dbg_logsoundcount`, `gint_dbg_logrequestsoundcount`). The request path only increments grid `sndrequests[]` counts. The consumer loop only zeroes grid counts, creates/moves `soundemitter` objects, and advances `gProgress.sound*` timestamps/counters. NOTHING on any of these paths writes unit/building/projectile/economy/AI/map state — no `SetGameObject*` combat field, no `obj.*`/`gProgress.*` sim field except the sound-owned counters/timestamps themselves. The sound grid (`gc_soundgrid_*`, `dmscript.global:70-75`) is a write-only-from-sim / read-only-by-sound mailbox: sim `_unit_RequestPlaySound` callers enqueue counts; sound drains them. RNG flows one way: G-stream → `rndind` → `sndtag`/handle → speaker. It never flows back into S-stream state, entity fields, or RNG keys.

**F6 [O] — Full donor call-site census (pick RNG reachable from):** positional: `weapon.script:1148` (musket volley) → `sound.script:534-544` → grid → `gui SoundControl :3190` → `_sound_EmitterPlaySound`; melee/work/death: `onaclanimationreachedattack.inc`, `onaclanimationreachedwork.inc`, `onaclanimationreachedconstruct.inc`, `ontagstates.inc` (unit + `building.inc:85,148-152`) → `_unit_RequestPlaySound` → same grid drain; walking: `gui.script:2872-2879` selection + `soundcontrolcounters.inc:98-195` → `_sound_EmitterPlayWalkSound` (round-robin); UI/selection: `showunitcontrol.inc:1015-1027` (select/building cues), `onmousedown.inc` (btnclick/cancel/drummer/bagpiper/officer), `doprogress.inc:84-89` (alarm + battle crossfade) → `_sound_PlaySound` (pick RNG #3, global `8000` radius). Group substitution (`sound.script:316-318`, `soundcontrol.inc:254-262`) is count-gated, never RNG-gated (and live `groupscount=0` for musket — DAUDIO-01 §2.1 `[O]`).

---

## 3. Still-[U] register — each with a fixed-seed audio-event trace and zero-mismatch termination (no stream invented)

General harness (owner-runnable; not run by this worker): temp config copy with `audio.enabled=true`, headless `false` NOT required — audio runs windowed (`main.gd:671-674`); scripted deterministic event tape (no gameplay RNG involved: spawn flat map, freeze AI/economy, fire a fixed list of `game.events` entries directly). Dump per audio call: `(seq, event_type, event_kind, prefixes, names_list, chosen_clip, pitch_scale, player_index, at, vol_db, last_play_key)`. Repeat `N=3`. Termination per item below; ANY mismatch keeps the item `[U]`; no test weakened; no donor value fitted.

| # | Item | Static state after this ticket | Exact trace + zero-mismatch termination |
|---|---|---|---|
| U-AUD-1 | Donor G-stream VALUES feeding `floor(random*(maxind+1))` (process-start QPC/TickCount seed, free-run) | Stream attribution settled `[D]` (G, §2-F1); VALUES unrecoverable statically and MUST stay uninvented | Trace T-AUD-CLIP-20: 20-event tape covering each live family once (musket/arrow/sabre/shotcannon/workwood/workstone/workconstruct/deathinf/deathbld/selectpeasant/btnclick/alarm/construct/watersplash/arrowimpact/cannonexpl/walkpea/walkinfmetal/walkcavfast/mortarballhitground). Port-vs-port with §5 fix applied: `N=3` runs, require byte-identical `chosen_clip` sequence AND `pitch_scale` sequence across all three (proves port determinism). Donor comparison asserts ONLY `sndlibind` family identity per event (from `sound.script:109-231` registrations), NEVER the exact variant index — a variant-index match against donor is explicitly NOT a pass criterion (G values free-run per process start). |
| U-AUD-2 | `gint_soundsteptick` initial value (walk round-robin phase) | Override mechanism `[O]` (§1); init value absent from recovered text | Trace T-AUD-WALK-12: 12 consecutive walk events of one family (`walkpea`, F5, `maxind=4`). `N=3` port runs require identical 12-clip cycle with period `maxind+1` starting from the same phase. Donor phase is NOT asserted (init unrecovered); only the cycle length/period is compared to donor (`count` from `sound.script:160-161`). Zero period mismatch → close the mechanism; phase offset vs donor stays documented, never fitted. |
| U-AUD-3 | Native mixer DSP: `RandomOffset` consumption curve, `Frequency`-group audition, isometric panning, `manager.cfg` 3D-key consumption | Script layer fully `[O]` (all zeros/fixed); engine layer UNVERIFIED (no new binary pass; DAUDIO-01 §4.4 open questions re-cited) | Trace T-AUD-SILENCE-3: 3 runs of the T-AUD-CLIP-20 tape with WAV capture; require (a) no crash/NaN on any `SetSndSoundRandomOffset(0)` equivalent, (b) identical WAV bytes across `N=3` after §5 fix, (c) spectral centroid of each clip within ±2% of the source Ogg (proves no hidden pitch shift). Engine-DSP parity vs donor stays UNVERIFIED regardless — this trace closes only port self-consistency, never donor fidelity. |

What is NEVER invented: any G-stream seed/sequence mapping donor process-start values to port draws; any `RandomExt` (S-stream) routing for sound; any nonzero `RandomOffset`/pitch curve; any `manager.lib` sound content (no such file exists); any `snd*.inc` content (no such files exist).

---

## 4. Port note for `variant3d/scripts/audio.gd` (file/line; owner/COORD applies — this worker changed no code)

**Required: seed the port audio RNG deterministically AND label it cosmetic-only with zero sim effect. No gameplay stream touched.**

1. `audio.gd:64` (`_ready`) / `audio.gd:76` (`start_music`) — ADD one owned generator (suggested shape, owner to word exactly):
   `var audio_rng := RandomNumberGenerator.new()` + `audio_rng.seed = <seed>` where `<seed>` = the run's pinned seed (`Data.RANDOM_SEED`, literal `20261113` in acceptance captures; `config.gd:134,540`, `game.gd:249` `[O]`). Seeding MUST happen at ready/start (before the first `play`), and the seed value MUST be logged alongside `config_sha256_file` in the capture manifest (same rule as determinism audit §5). Rationale: makes T-AUD-CLIP-20 pass port-vs-port while remaining independent of all gameplay streams.
2. `audio.gd:360` — route the clip pick through it: `names[audio_rng.randi() % names.size()]`. Covers U-AUD-1 port side. Do NOT route through `rng`/`sim_rng`/`gen_rng`/`brng`/`delphi_rng` (gameplay streams per RNG-LEDGER §4/§7); audio draws must never advance or be advanced by sim draws.
3. `audio.gd:368` — route the pitch through it AND cap the donor gap: `p.pitch_scale = audio_rng.randf_range(0.92, 1.08)` with a `PORT APPROXIMATION — no donor pitch RNG (sound.script:476,523 DefRandomOffset=0 [O])` comment. Optionally gate behind a config flag defaulting ON for current audible behaviour; setting it to `1.0` is the donor-exact audition path for U-AUD-3 comparisons. Either way the draw stays on `audio_rng`, never on a gameplay stream.
4. `audio.gd:334-337` (0.09 s `Time.get_ticks_msec()` dedup) — KEEP as Class-N hazard with a comment cross-ref to determinism audit N4: it is wall-clock/frame-time dependent by construction. For pixel captures use a temp config with `audio.enabled=false` (determinism audit §1-N4 experiment); for audio traces keep it enabled and identical across the `N=3` set. Preserve-only — document, do not remove.
5. `audio.gd:150-253` ambient `_process` + `audio.gd:466-477` `selection_clip` — label in comments: `COSMETIC-ONLY — reads game/camera/terrain, writes no sim state; deterministic (counter/clock-gated, no RNG)`. `selection_clip` is already deterministic (count-based modulo, D05-selection PORT APPROX); do NOT add RNG to it.
6. Invariants for the owner diff review: (a) no new reads of `audio_rng` outside `audio.gd`; (b) no writes from `audio.gd` to `game`/entity/RNG/s Toda state (current code already satisfies this — `play()` only sets `AudioStreamPlayer` fields — keep it that way); (c) `main.gd:1770-1820` fan-out stays one-way (`events` → `_play`; `events.clear()` retained); (d) save schema untouched (no `audio_rng` state persisted — reseeded per run by rule 1, exactly like the donor's per-process G seed).

---

## 5. Explicit non-claims and file discipline

- NO PARITY CLAIM. Closed items (clip-pick formula ×3 sites, zero pitch/pan RNG, walk round-robin override, request-path RNG absence, one-way sim→sound dataflow, stream = Delphi G not S) rest on donor TEXT `[O]` with `path:line` above; open items (G VALUES, step-counter init, native DSP consumption) list exact traces in §3. No donor binary executed, no Godot process launched, no capture produced, no git touched.
- No approximation substituted for a resolved law. The two port inventions on this path (`randi() % size` on the global RNG, `randf_range(0.92,1.08)` pitch) are named with replacements in §4 that isolate them on a seeded audio-only stream without touching gameplay determinism.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` target paths; prior binary evidence (offsets `0x2b944a…0x500106`) is re-cited, not re-run.

*End of DEC-U-AUDIO-RNG.*
