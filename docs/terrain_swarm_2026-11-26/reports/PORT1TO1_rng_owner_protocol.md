---
id: PORT1TO1-RNG-OWNER-PROTOCOL
worker: RNG-OWNER-PROTOCOL (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "The single ordered, owner-only experiment packet that settles P0-7 (S-vs-G RNG stream split): fixed seed 20261113 harness + X21 20-vector oracle, exact per-site log schema, pinned donor state-dump breakpoints, restart/seed-change checks, full-series zero-mismatch termination, and outcome-to-port-change (which sites route to G vs S, what stays [U])."
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_PARITY_CLAIM]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/captured by this worker; all donor facts are re-cited [O]/[D] from the pinned upstream reports. The debugger breakpoints in §3.5 and the harness in §2-§6 are SPECIFIED, not performed. Workers are forbidden to execute the donor; only the owner/COORD may run either layer."
scope_guard: "No repo code/asset/config/shader/Godot/git change, no gate/runner job, no capture, no Craft Anything native call, no investigation memory written. Exactly one repository file written: this report."
upstream: "DEC_U_rng_ledger.md §§1-7 (G1a-g, S/G draw ledger, X21 fixture, port change list); DEC_U_gen_seed.md §§1-2/§5 (Delphi seeder 0x4033b8, 0x8f2008, reseed census, probes); X21_rng_vectors.md §§4-9 (LCG bytes, 20-vector fixture, word-order/zero-state, risks XU1-XU8); PORT1TO1_determinism_audit.md §§1-6 (Class-N exclusions, N3 fisher); PORT1TO1_owner_decisions.md §6 (P0-7); PORT1TO1_u_register_update.md §1 P0-7; PORT1TO1_handoff_checklist.md §3 P0-7 (no dedicated packet — this file fills that gap); spec/02_SEED_AND_RNG.md; variant3d/scripts/{game,data,audio}.gd (read-only current-tree anchors)."
harness_class: "RUNTIME-HARNESS (owner/COORD fixed-seed, no donor binary) + owner-only donor-side NATIVE state-dump breakpoints (no GPU frame); workers forbidden to run or promote either layer"
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
verdict: "P0-7 stays OPEN until the owner/COORD executes the full series with 0 mismatches. Nothing in this packet closes donor parity; six-condition chain 0/6; no donor GPU A/B frame; no approximation; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 RNG — single owner-only S/G stream-split experiment packet (read-only, no parity)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **Why this file exists.** `PORT1TO1_handoff_checklist.md:136` records that P0-7 is the one P0 with **no dedicated owner packet**. This report is that packet. It specifies an experiment only; it retires no `[U]`, wires no stream, invents no draw, and makes no parity claim.

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor byte/text or verbatim port file line, with its report cite), `[D]` (deterministic arithmetic/control-flow consequence of `[O]`), `[I]` (interpretation, flagged), or `[U]` (UNVERIFIED — retired **only** by owner/COORD execution of §2-§6 under the §6 zero-mismatch rule).

- **This worker ran nothing.** No donor binary, no Godot process, no gate, no harness, no capture, no frame/hash comparison, no Craft Anything native call. All donor constants, VAs, evidence ids and experiment ids are **re-cited pinned records** from the reports in `upstream`; they were not re-lifted. Current-tree port anchors were read read-only and carry a drift warning (§1.4).
- **Owner-only, two layers.** (L1) §2-§4 and §6 port harness: owner/COORD, headless fixed-dt, pinned config, literal seeds. (L2) §3.5 donor-side native state-dump breakpoints at pinned VAs: owner-authorised debugger only. **Workers are forbidden from both.** L2 is a native state dump, **not** a donor GPU A/B frame; no capture is part of this packet.
- **No stream or draw invented.** G-stream *values* are never snapshotted into a fixture (they free-run from a process-start QPC/TickCount seed, `DEC_U_gen_seed.md §2.2`). Count-only applies to G. Any `m+n` victim-loop count, `minesdensity`/generator-version count, or signed-`key0` behaviour is **counted/asserted, never guessed**. The single-survivor rule: a site drawing from the wrong stream, or an extra/missing draw, is a FAIL, not a value to fit.
- **No parity claim.** A zero-mismatch result yields a `[D]+harness-id` *internal* result consistent with donor-text-pinned algebra; it is **not** a donor runtime observation. `parity.status=UNVERIFIED`, `parity.claim=NONE`, `visual_parity_claim=false` before, during and after this packet. A matched-seed donor-vs-port A/B remains a separate owner obligation (`X39_ab_feasibility.md §3`) and no such frame exists.

**Load-bearing port fact `[D]` (current tree, VERIFIED read-only):** `variant3d/scripts/game.gd:239` declares `sim_rng := DonorRandomExt.new()` as a **single** skirmish-sim S stream; `game.gd:9796` self-describes it as `"single donor RandomExt stream (no split claimed)"`. All G-attributed sites currently draw from `sim_rng` (e.g. `_misc_random_int` at `game.gd:5919-5920`, headshot at `:7581`, capture jitter at `:8547`, easy-gate at `:8622`, AI die rolls at `:7542/:8676`). `audio.gd:69` is a separate **cosmetic** `audio_rng` seeded from `Data.RANDOM_SEED` (`:75`) and isolated from sim streams by contract (`:68/:382`). **The S/G split remains `[U]-G1`.** Nothing in this report changes any of it.

---

## 1. What is already pinned (carry-forward; do not re-open in the harness)

### 1.1 Settled donor algebra `[O]/[D]` — the bodies the harness freezes

| Scope | Pinned content | Source |
|---|---|---|
| S stream (`RandomExt`) | `s ← (s×0xFC0D + 0x3C6EF35F) & 0xFFFFFFFF`; `RandomExt = f32(s / 4294967296.0)` ∈ [0,1); `GetRandom(n)=floor(RandomExt*n)`; `GetRandomRange(a,b)=a+floor(RandomExt*(b-a+1))`. Period 2^32; no statistical-quality claim. | `X21_rng_vectors.md §4.1-4.5`, `DEC_U_rng_ledger.md §2`, `spec/02_SEED_AND_RNG.md §2` |
| `key0` discarded | `0x406718` product cross term lands in EDX (high word), discarded by `0x4067b8` mod 2^32; `(K0,K1) ≡ (0,K1)` for **every** draw incl. the first. D02 §4.2 "first-output" sentence superseded. | `X21_rng_vectors.md §4.3/§5.2`, `DEC_U_rng_ledger.md §2` |
| Output rounding | `fstp dword` at `0x60f68e` is the only rounding: f32, not bare double. D02 decimals were unrounded doubles (`0x3C6FEF6C` → `0.236083001`, not `0.236082996`). Emulate with a `Float32Array` round-trip. | `X21_rng_vectors.md §4.5/§6` |
| `s=0` | Not a fixed point: draw #1 = `0x3C6EF35F` → `0.236067966`; `gcd(64524,2^32)=4 ∤ C`, no fixed point; no state guard in the raw bytes. Live-replay equivalence stays `[U]`. | `X21_rng_vectors.md §4.4` |
| G stream (`Delphi Random`) | `d ← (d×0x8088405 + 1) & 0xFFFFFFFF`; `Random(256)` returns `d>>>24` (byte); float `Random` scales by `2^-32` at `0x8f206c`. `RandomInt = floor(Random*32768)`. | `DEC_U_gen_seed.md §2.1`, `X21_rng_vectors.md §6.1`, `DEC_U_rng_ledger.md §1/§2` |
| G seeder | `sub_4033b8`: QPC-low-dword else `GetTickCount`; 3 static callers, **none** on generation/skirmish path. No `SetRandomKey`/`SetRandomExtKey64` touches G. G free-runs from process start; no per-stage G reseed. Image slot `0x8f2008 = 0`. | `DEC_U_gen_seed.md §2.2-2.3`, `DEC_U_rng_ledger.md §1` |
| `round()` | Delphi `System.Round` = Bankers half-to-even; port `donor_round` correct (`data.gd:1273` current tree; report-era `:1206-1214`). Native `@Round` **address** is the only open tail (G1-a). Never `floor(x+0.5)`. | `DEC_U_rng_ledger.md §3`, `PORT1TO1_owner_decisions.md §6` |
| Per-site **order** | All site orders in `DEC_U_rng_ledger.md §4` are `[O]`. Many per-site **counts** remain `[U]`-G1 (S3-g, S5-c, AI attribution). | `DEC_U_rng_ledger.md §4/§5` |

### 1.2 The two seeding contexts — keep them distinct (do not conflate)

1. **Harness run seed = literal `20261113`.** The port config literal used for every fixed-seed replay (`PORT1TO1_determinism_audit.md §0`; `handoff_checklist.md §4.5/§4.9`). This is the seed for the port-vs-port state-hash matrix, restart checks and Class-N exclusion. It is **not** the X21 fixture key.
2. **X21 oracle fixture = synthetic pair `(key0=0x44A108F9, key1=0x00000001)`.** A synthetic test input (a donor-observed word used as a convenient high word + synthetic low word), **never a claimed donor seed** (`X21_rng_vectors.md §5`, `DEC_U_rng_ledger.md §4-S6`). The first S state is then `M+C = 0x3C6FEF6C`. Because `key0` is discarded, the effective seeding word is `key1=0x00000001`. The owner injects this pair into the deterministic model for the L20/S6 oracle assert; it must **not** be written into `Data.RANDOM_SEED` or presented as a donor seed.

`20261113` and `(0x44A108F9, 0x00000001)` are two different seeds with two different roles. No mapping between them is asserted.

### 1.3 Pinned VAs `[O]` — what exists and what the harness means by them

| VA | What it is | Use in this packet | Source |
|---|---|---|---|
| `0x60f64c` | `RandomExt` function entry (`0x60f64c-0x60f696`); state lo `0x9048d4`, hi `0x9048d8`; helpers `0x406718`/`0x4067b8`; f32 divisor `0x60f698 = 4294967296.0` | **S-stream state-dump breakpoint** (§3.5): log `s` before/after and the f32 return | `X21_rng_vectors.md §2/§4.1`, `DEC_U_rng_ledger.md §1 P2` |
| `0x403a0c` | Delphi `Random(256)`: `imul edx,[ebx+0x8f2008],0x8088405; inc edx; mov [ebx+0x8f2008],edx; mul edx; mov eax,edx` | **G-stream state-dump breakpoint** (§3.5): log `d` before/after and returned byte `d>>>24` | `DEC_U_gen_seed.md §1/§2.1` |
| `0x8f2008` | Delphi RNG state slot (u32; image default `0`); sole writer besides `0x403a0c` is seeder `0x4033b8` | **G-state dump point** (§3.5): record process-start seed and per-draw state; proves G is never reseeded by sim setters | `DEC_U_gen_seed.md §1/§2.2` |
| `0x8f206c` | `2^-32` scaling constant for float `Random` | **G-float scaling anchor** (§3.5): confirm the float-G divisor; do not substitute `4294967296.0` (that is the S divisor) | `spec/02_SEED_AND_RNG.md §3`, `DEC_U_rng_ledger.md §1 P3` |

Supporting (carry-forward, not new breakpoints): seeder `0x4033b8`; S state `0x9048d4/d8`; divisor `0x60f698`; setters `GetRandomKey 0x60f69c`, `SetRandomKey 0x60f6a4`, `SetRandomExtKey64 0x60f6dc`; five same-constant LCG instances `0x60f65d, 0x7281ca, 0x72d2d1, 0x809657, 0x8096a1`. **No native scheduler/driver VA is recovered** — that is `DEC_U_tick_driver.md §3 U-D1 / §5`, explicitly `[U]`; do not invent one here.

### 1.4 Current-tree port anchors `[O]` (read-only VERIFIED; re-read before applying any §7 change)

Report-era cites (`DEC_U_rng_ledger.md §7`, `PORT1TO1_owner_decisions.md §6`) have drifted against the 2026-11-27 tree. Both are listed; **apply-time re-read is mandatory**.

| Anchor | Report-era cite | Current-tree cite / content | Label |
|---|---|---|---|
| Sim S stream | `game.gd:176,509,7723,7836-7837` | `game.gd:239 sim_rng := DonorRandomExt.new()`; `:378/:601 set_state(Data.RANDOM_SEED)`; `:9796 "single donor RandomExt stream (no split claimed)"` | S stream landed; split `[U]` |
| Birth draws | `game.gd:6547,7317,7431-7433,7616-7619` | `game.gd:3119 birth_uniqrnd = sim_rng.random_f32()`; `:3120 birth_progresstick = sim_rng.get_random(32)` | S draws landed |
| `RandomInt` | `game.gd:5406/5412` | `game.gd:5919-5920 _misc_random_int()` still `floorf(sim_rng.random_f32()*C1RAND_TO_RANDOM)` | **G site on S — must rewire on green** |
| S wrapper | new in §7 | `game.gd:5926 _donor_get_random(n) = sim_rng.get_random(n)` | f32 wrapper present; check wrapping |
| Scatter / pick / orientation | `game.gd:6512,6527,6537` | `game.gd:5952-5953` scatter (2×sim_rng), `:5960` pick, `:5963` orientation | S sites |
| `frnd` | `game.gd:7422/7454/7463/7493` frnd via sim_rng | S3-b frnd landed | S site |
| Headshot / AI / easy-gate / capture jitter | `game.gd:6603,6567,7203,7170,7104` | `game.gd:7581 headshot_roll`, `:7542/:8676` AI die rolls, `:8622` easy-gate, `:8547` cap jitter — all still `sim_rng` | **G sites on S — rewire on green** |
| Fisher target | `game.gd:8127-8130` | `game.gd:8208-8209` now `sim_rng.random_f32()` (Class-N hazard neutralised port-internal; donor stream attribution still `[U]`) | `[U]` attribution, not donor claim |
| `donor_round` | `data.gd:1206-1214` | `data.gd:1273 donor_round()`; `:1505/:3598` callers | keep; G1-a tail on native address only |
| Save state | `game.gd:7723` | `game.gd:9391-9394` keys `rng_state/gen_rng_state/sim_rng_state`; `:9512-9521` restore with seed fallback | additive-only; no version bump |
| Cosmetic audio | `DEC_U_audio_rng.md` | `audio.gd:69 audio_rng`, `:75 seed = Data.RANDOM_SEED`, `:383` clip pick | isolated; never route sim draws through it |

---

## 2. THE harness — one ordered owner/COORD matrix (specified, not performed)

### 2.1 Admissible setup (no donor binary; Class-N excluded)

1. **Engine contract:** opt-in fixed-step path of `PORT1TO1_fixed_step_plan.md §2-§3` (`--deterministic-capture --capture-ticks N`, literal `--seed 20261113`, `deadline_ms=0`, `watchdog=0`, authoritative 1280×720 viewport, CPU fallback refused). For a pure state-hash battery, headless fixed-dt is admissible **only** if N3 fisher `randf()` is code-neutralised (`game.gd:8208-8209` currently routed to `sim_rng`) and no fishing delivery occurs; otherwise the run is inadmissible (`PORT1TO1_determinism_audit.md §1 N3`).
2. **Excluded paths:** `--seed random`, menu Random button, wall-clock watchdog, frame-paced stepping/frame-count screenshots, async-load yields, 800×600 GPU fallback, `load_save` seed rewrite, audio RNG/wall-clock dedup (`audio.gd:334-337,383`). Record config SHA-256 and a Class-N "none active" assertion in the run manifest.
3. **Instrumentation is additive and labelled**; it must not change sim order, RNG consumption, save keys or audio isolation. No donor file opened for write.
4. **Fixture isolation:** the `(0x44A108F9, 0x00000001)` oracle is applied **only** inside the deterministic model / boot assert for L20-S6; it never overrides the harness run seed `20261113` and is never labelled a donor seed.

### 2.2 Ordered execution (do top-to-bottom; ★ = stop-and-gate)

| Step | Act | Gate / output |
|---|---|---|
| 1 | Pin build, config SHA-256, harness seed `20261113`, fixture pair, startid set, speed factor, player roster. Refuse if any Class-N path active. | ★ manifest fields immutable for all runs |
| 2 | Reset S stream to fixture pair for the oracle context; reset to `20261113` for the harness context; clear both counters; record G state dump at start (value recorded, not asserted). | ★ oracle context: first S state must be `0x3C6FEF6C` |
| 3 | Advance the sim at fixed dt; at every pinned site emit the §3 schema; append each draw to the stage-keyed ledger `(stage_id, generator_version, stream_name)` (`X21_rng_vectors.md §6.2`). | one log line per site per draw; no silent draw |
| 4 | Cross-check every S draw against the X21 oracle (§4-L20) and every G draw as **count only** (§3.4). | ★ wrong stream / wrong count / extra draw ⇒ FAIL |
| 5 | Run all six series R20/L20/C300/U50/F1M/K0/A600 in full (§4). | ★ any single mismatch ⇒ item stays `[U]`, no wiring |
| 6 | Append process restarts and seed-change checks (§5); compare canonical state hashes byte-for-byte. | ★ restart/seed-change mismatch ⇒ FAIL |
| 7 | Only if **all** series and checks are 0-mismatch: flip the specific G1 sub-item to `[D]+harness-id` and apply §7. Otherwise freeze labels. | no partial credit; no threshold retune |

---

## 3. EXACT per-site log schema (the load-bearing packet)

Every line is keyed `(series, seed_context, run_kind, tick, event_seq)`. Canonical JSON with sorted keys and full Float precision. The canonical state hash covers §3.1-§3.6; `sha256(canonical_json)` is authoritative.

### 3.1 Frame header
`tick`, `time_s` (must equal `tick/32` at `Data.FPS=32`), `dt`, `series_id`, `seed_context` (`20261113` | `X21_fixture`), `candidate_id`, `stream_counters{S,G,local}`, `sha256_state_so_far`.

### 3.2 Per-site RNG record — one per pinned site, one per draw

Fields, all mandatory:

| Field | Meaning / rule |
|---|---|
| `site_id` | Donor cite (`unit.script:<line>`, `weapon.script:<line>`, `miscext*.script:<line>`, `dmscript.global:<line>`) **and** current-tree port anchor; from `DEC_U_rng_ledger.md §4` S0-S5 |
| `stage_key` | `(stage_id, generator_version, stream_name)` — version gates change counts; never collapse stages |
| `stream` | exactly one of `S`, `G`, `stored`, `0` — recorded, never inferred from the port variable name |
| `draw_ordinal` | 1-based ordinal **on that stream**; S and G numbered independently, never merged |
| **S only:** `s_hex`, `s_dec`, `f32_hex_le`, `f32_dec` | S state at the draw and its float32 output + IEEE-754 little-endian bits — strongest comparison key (`X21_rng_vectors.md §5.1`). Derive bits via the `Float32Array` round-trip, **not** by hand-copying a Markdown table (see §4 oracle caveat). |
| **S only:** `n_literal`, `floor_result` | `GetRandom(n)` denominator and `floor(f32*r*n)` result; include `GetRandomRange` edges in F1M |
| **G only:** `d_before`, `d_after`, `byte_or_float`, `scale` | Delphi state u32 before/after (`0x8f2008`), returned byte `d>>>24` for `Random(256)` or float `d×2^-32` (divisor `0x8f206c`); scale literal recorded. **G values are logged for provenance only and NEVER compared to a fixture — count-only.** |
| `reseed_bool`, `key0`, `key1`, `reseed_target` | set for reseed sites (§3.3); `reseed_target` ∈ {S (`0x9048d4/d8`), G (`0x8f2008`)}. G must show `reseed_bool=false` at every sim setter. |
| `stored_value` | for `stream=stored`: the stored `uniqrnd` float and its owning unit/projectile id — **not a draw** |
| `n_before`, `n_after` | per-site counters, to detect extra/missing draws |

### 3.3 Reseed-point record (key0/key1)

Log **every** `SetRandomKey(k)` and `SetRandomExtKey64(k0,k1)` boundary with: `site`, `k0`, `k1`, `target_stream`, `identity_bool` (same-key verbatim reseed), `draws_reset_bool`. Generation boundaries are boundary provenance only (`initmapgen.inc:99,146`; `dogenerate.inc:1100/1161/1177/1213/1538/1616/1772/1909/1927`; `generatemap.inc:216/513/774`) — they are **GENSEED-owned** (`DEC_U_gen_seed.md §2.3`) and are not re-litigated here; the skirmish-sim setters are identity reseeds (`PORT1TO1_owner_decisions.md §6`, `game.gd:391`). Assert: `key0` never changes any S draw; no sim setter writes `0x8f2008`.

### 3.4 G count-only rule (do not violate)

G draws are logged with state/byte for provenance, but the **only** admissible G assertion is the draw **count** per site and the fact that the site is G-attributed. G values vary with process-start wall clock (`0x4033b8`) and can **never** be snapshotted into a fixture. A G *value* mismatch against any expected number is **not** a failure; a G *count* or *stream* mismatch is a FAIL.

### 3.5 Owner-only donor-side native state-dump breakpoints (L2; no GPU frame)

Executable **only by the owner** on pinned `t_87f0f3c130b0`; never by a worker; no donor GPU frame is captured.

| Breakpoint / VA | Dump at each hit | Purpose / termination |
|---|---|---|
| `0x60f64c` (`RandomExt` entry) | u32 `s` at `0x9048d4/d8` before and after; f32 return at `0x60f68e` (`fstp dword`); divisor `0x60f698` | S arithmetic and per-draw state; S hex/f32 must match the X21 sequence with 0 mismatches |
| `0x403a0c` (Delphi `Random` entry) | u32 `d` at `0x8f2008` before/after; returned byte `d>>>24` (or float via `0x8f206c` scale) | Confirm G recurrence and that `d` advances once per G draw; prove no sim setter writes it |
| `0x8f2008` (G state slot) | u32 at process start (seeder `0x4033b8`) and at each stage boundary | Terminate when restart changes the seed (QPC/TickCount) and same-process regenerations continue the stream (no per-map G reseed) |
| `0x8f206c` (`2^-32` divisor) | read the scaling constant | Confirm float-G scaling; do not substitute the S divisor `0x60f698` |

**Termination for L2:** every dumped S value equals the model with 0 mismatches; every G advance equals one draw with 0 missed hits; restart changes `0x8f2008` while S reseeds remain identity. No donor frame, no capture, no parity from L2.

### 3.6 Canonical state hash inputs
`players`, `entities`, `projectiles`, both stream counters, stage-keyed ledger, per-player deadlines, banks, `uniqrnd` per unit/projectile, `lasttimecheckcapture` per capturer, and the §3.3 reseed log (`DEC_U_rng_ledger.md §5`, `PORT1TO1_owner_decisions.md §6`). Float deadlines are never quantised (`PORT1TO1_tick_owner_protocol.md §3`).

---

## 4. The six series — full-run termination from the landed reports

General harness rule (`DEC_U_rng_ledger.md §5`): fixed fixture seed where specified, `rng_model.py` + `test_vectors.json` as oracle (temp path `...\rng_verify\`, outside repo), headless fixed-dt, canonical JSON state hash. **Run the FULL series; ANY single mismatch keeps the item `[U]` and forbids wiring; zero mismatches across the FULL series closes it.** Never fit/invent a draw order or stream.

| Series | What it asserts | Termination (0-mismatch) | Source |
|---|---|---|---|
| **R20** | `donor_round()` over the 23-value set incl. ties `{3.25,6.5,13,8.125,16.25,24.375,5.5,11,16,1,2.5,5,7.5,2*1.625,…,15*0.5}` plus all 14 PUSSTRELA `time_frames` via `donor_weapon_row()` | Expect `{3,6,13,8,16,24,6,11,16,1,2,5,8,…}`; zero mismatches → drop `[U]-G1-a` on `donor_round`; any → single-site override table, **never** `floor(x+0.5)` | `DEC_U_rng_ledger.md §3 item 5/§5 G1-a`, `ai.gd:1549-1551` |
| **L20** | Fixed-seed 1v1 §4-S6: 20 S draws vs X21 §5.1 (`s` hex + `bits LE` + `floor(r×{3,5,10,256})`); G draws **count-only** | Exact S sequence `3C6FEF6C…A2C21855`; any S divergence ⇒ `[U]`; G value mismatch is not a failure | `DEC_U_rng_ledger.md §5 G1-b`, `X21_rng_vectors.md §5.1` |
| **C300** | Flat map, cannon/archer/musket shooters × fixed target at 10/20/30 m, 100 shots each (300) | S draws/shot exact: musket 1(frnd)+S3-c 7; archer 3+7; cannon 3+7; `stand` +2; `random1/random` +4 (1 rotspeed + 3 ThrowRandom). Zero count mismatches → close; any extra draw ⇒ `[U]` | `DEC_U_rng_ledger.md §5 G1-c` |
| **U50** | Spawn 50 units, log per-unit `uniqrnd` vs S positions 1,3,5,7,…; fire 50 musket shots, assert scatter-precedes-frnd (S3-b) | Zero mismatches → close; scatter-before-frnd violation ⇒ `[U]`. Corrects the stale `game.gd:6547` comment | `DEC_U_rng_ledger.md §5 G1-d` |
| **F1M** | Sweep `n∈{1..512,100000}` × all 20 S values: `floor(f32(r)*n)` vs `floor(f64(r)*n)` + `GetRandomRange` edges | Zero divergences → document f32 promotion safe for the tested range (still `[U]` beyond); boundary divergence → wire f32 path verbatim | `DEC_U_rng_ledger.md §5 G1-e`, `X21_rng_vectors.md §8 item 1/XU4` |
| **K0** | `key0 ∈ {0x00000000, 0x44A108F9, 0x80000000, 0xFFFFFFFF}` × `key1=0`, first-draw assert | First two expect u32 model (`0x3C6EF35F`, `0x3C6FEF6C`); latter two asserted **without claiming donor behaviour** (no donor run); any port crash/NaN ⇒ `[U]`, keep guard | `DEC_U_rng_ledger.md §5 G1-f`, `X21_rng_vectors.md §8 item 3/XU5` |
| **A600** | 1 AI vs 1 idle human, 600 s, log every AI/capture/economy draw with stream tag | Guard-sampler S counts + die-roll G counts + slow-death S `floor(·*300)` per §4; headshot G gate + zero-S bonus. Zero mismatches → close; any stream flip ⇒ `[U]` | `DEC_U_rng_ledger.md §5 G1-g` |

**Oracle provenance caveat `[O]`:** the two landed Markdown tables carry a row-7 `bits LE` discrepancy for `s=0x089D0992` (`X21_rng_vectors.md §5.1` prints `99d0093d`, `DEC_U_rng_ledger.md §6` prints `99009d3d`). Use the canonical `test_vectors.json` (X21 §5) as the authoritative oracle and **re-derive bits via the f32 round-trip**; do not hand-transcribe either Markdown column into an assertion. No value is invented to resolve this.

**Explicit non-claims:** G values (free-run), `m+n` victim-loop counts (S3-g, spawn-gated), `minesdensity`/generator-version counts (S5-c), and signed-`key0` donor behaviour (K0 latter two) are never fabricated. `GenerateMapRandKey` / saved-map key bytes (G1-h) are **generation-owned (GENSEED)** and out of scope here.

---

## 5. Restart / seed-change checks

| Check | Procedure | Termination / meaning |
|---|---|---|
| Same-seed restart (harness) | Run the identical `20261113` job twice into fresh dirs; compare canonical state hash per tick and per-frame `sha256_pixels` | Byte-identical across both runs ⇒ S stream determinism proven; any mismatch ⇒ Class-N defect, not this item |
| Process restart (G) | Dump `0x8f2008` at process start on two launches; run a fixed G draw sequence | Seed **must change** with QPC/TickCount; G values across restarts are never asserted equal; proves wall-clock G source and no per-map G reseed |
| Same-process regeneration (G) | Regenerate a second map in one process; dump `0x8f2008` at each stage boundary | G stream continues (no per-map reseed) — 0 missed advances; a per-map reset would be a FAIL |
| Seed-change, `key0` only | With `key1` fixed, vary `key0`; dump first three S floats | **Bit-identical** S streams (key0 discarded, X21 §5.2) — confirms live-path key0 discard; divergence ⇒ `[U]` |
| Seed-change, `key1` ±1 | With `key0` fixed, vary `key1` by ±1; dump first three S floats | S stream changes; confirms only the low word seeds the recurrence |
| Reseed identity | At every sim `SetRandomKey`/`SetRandomExtKey64` boundary, log `k0/k1` and S state after | Same-key verbatim reseeds only (`game.gd:391`); no `seed+si*1000003+ver*10007` derivation reintroduced; no G write |
| Restart after save/load | If a save is used, assert `d.seed == 20261113` and restored `rng/gen/sim_rng` states byte-equal before continuing | Otherwise inadmissible (`PORT1TO1_determinism_audit.md §1 N9`, `game.gd:9391-9394/9512-9521`) |

---

## 6. Zero-mismatch termination criteria (global, no partial credit)

A `[U]` G1 sub-item retires **iff** its named tuple repeats with **0 mismatches** across the **full** series and the restart/seed-change checks. Any single-tick divergence, missing dump, wrong-stream draw, extra/missing draw, closed gate, or path mixing ⇒ that item **stays `[U]`**, its candidate is deleted, and the port keeps its current label. "Close", a metric, an average, a threshold retune, a retry-until-green, or a port-internal replay pair never counts.

- **S correctness:** exact X21 sequence `3C6FEF6C…A2C21855`, `s` hex + `bits LE` + `floor(r×{3,5,10,256})` all byte-identical; 0 mismatches.
- **G correctness:** draw **counts** and per-site attribution exact; G **values** excluded from assertion by design (count-only). A G value mismatch is not a failure; a count/stream flip is.
- **Per-site counts:** exact at S0/S1/S2/S3/S4/S5 (`DEC_U_rng_ledger.md §4`); spawn-gated `m+n` and version-gated counts may be counted only, never assumed. `uniqrnd` is a **stored value** (S0-a), not a draw; `frnd` follows scatter (S3-b).
- **Reseeds:** key0 discarded; no G write by sim setters; identity reseeds only.
- **Seed** `20261113` literal in every harness manifest; config SHA-256 pinned; Class-N "none active" asserted; no `watchdog:`/`cli: wall-clock limit reached` in stderr.
- **After all six series green:** flip only the specific G1 sub-item to `[D]+harness-id` with its tuple + loser list; apply §7. Everything else stays `[U]`. `parity.status` remains UNVERIFIED — this is internal self-consistency against donor-text-pinned algebra, not a donor observation.

---

## 7. Outcome → exact port change (owner/COORD applies; NO edits made here)

Every row fires **only** on its zero-mismatch result. All anchors must be re-read at apply time (§1.4 drift note). None touches save version, existing v5 keys, demo/mill/builder hooks or I11 seam paths.

### 7.1 Per-site routing — which sites go to G vs S (from `DEC_U_rng_ledger.md §4/§7`)

| Route | Sites (donor cite) | Exact port change |
|---|---|---|
| **→ G stream** (`delphi_rng`, new second `RandomNumberGenerator`, seeded at process start from wall-clock per `0x4033b8` — **never** from `_reseed_stage`) | `RandomInt = floor(random*32768)` (`misc.script:493-498`); headshot gate `random<0.05` (`miscext2.script:420`); AI die rolls building/supermortar/cannon/mortar/peasant (`miscext.script:1147-1173`); easy-gate `random>0.5` (`:1082`); capture jitter init `random*TimeCheckCapture` (`unit.inc/initial.inc:320` etc.); `ResetProgressPlayer` 7 jitters (`miscext2.script:1887-1907`); famine/rebellion `RandomInt` (`unit.inc/nothing.inc:482/487-497`); friendly-fire reseed `SetRandomKey(floor(random*MaxInt))` (`unit.script:5300-5332`, `_unit_DoProjectile :11528-11554`); `uniqrnd=0 → random` Delphi fallback (`weapon.script:1046-1051`); PlayOnce `volumeclippedfreq<random` (`weapon.script:1011`, explicitly non-synced) | Rewire the listed sites from `sim_rng` to `delphi_rng` (current-tree: `game.gd:5919-5920, 7581, 7542, 8676, 8622, 8547`; report-era `:5406, 6603, 6567, 7203, 7170, 7104`). Do **not** retune any threshold to pass. Save `delphi_state` as an additive key only. |
| **→ S stream** (`sim_rng`, with f32 `DonorRandomExt`) | `uniqrnd` spawn (S0-a `unit.script:2726`); `progresstick floor(RandomExt*32)` (S0-b `:2706-2707`); `GetRandom/GetRandomRange` (`dogenerate.inc:990-997`); slow-death `GetRandom(300)` (`miscext.script:1152`); guard sampler (`unit.script:3638-3668`); S3-b scatter 2× + frnd (`unit.script:11520-11554`); S3-c pick 1 + orientation 6 + stand pitch 1 (`weapon.script:1046-1051`); rotspeed 1 + ThrowRandom 3 + stand 2 (`weapon.script:936-939,1135-1157`); DoExplode child rolls (`doexplode.inc:139-224`); randomsimulate seed + rotation (`miscext2.script:641-728`) | Keep on `sim_rng`; add `_donor_get_random(n) = floorf(f32(rng.randf())*n)` wrapper (current `game.gd:5926`) at every §4-S `GetRandom` site. Never bare double. F1M-S6 scatter law (`maxdisp_m = dist_m*dispertion_px_mount/2000`, zero-dispersion scatters nothing, order scatter→scatter→frnd) stays verbatim. |
| **stored / 0 draws** | `uniqrnd` stored value (`:2726`); `floor(uniqrnd*500)` headshot bonus (`:437`); `gametimewithrnd := gametime+uniqrnd` anchor; `DoExplode` resync `SetRandomKey(floor(uniqrnd*MaxInt))` (`:12`); airburst `FramesToTime(round(...))`; market/fear arithmetic | Never instrument as a draw; log `stored_value` only. `donor_round` stays Bankers; no `floor(x+0.5)` anywhere on this path. |

### 7.2 Labelling / metadata changes on green
- Extend `data.gd:1636-1644` (report-era; re-read) ledger consts with `stream` tags: `S` on `GetRandom/GetRandomRange/slow_death/guard_sampler`; `G` on `RandomInt` + `damage_headshot` gate; `stored` on `floor(uniqrnd*500)`. Add cited consts `DONOR_DELPHI_M=0x8088405`, `DONOR_DELPHI_C=1`, `DONOR_LCG_M=64525`, `DONOR_LCG_C=1013904223`.
- Keep `donor_round` and identity reseeds (`game.gd:310/319-321` report-era; `:391` current); drop `[U]-G1-a` only on R20 green. Keep the native `@Round` address tail `[U]` until separately anchored.
- Port `rng`/`gen_rng` remain Godot `RandomNumberGenerator` — **PORT APPROXIMATION**, not these recurrences — until wrapped. `audio_rng` stays cosmetic and isolated; never route sim draws through it.
- Telemetry rule: `visual_parity_claim=false`; each retired sub-item becomes `[D]+harness-id` with tuple and loser list.

### 7.3 What stays `[U]` regardless of a partial green
- G stream **values** (free-run; count-only forever), the native `@Round` **address** (G1-a tail), AI/capture/economy per-line attribution until A600 green, spawn-count-gated `m+n` (S3-g), `minesdensity`/generator-version counts (S5-c), signed-`key0` donor behaviour (K0 latter two), f32-vs-f64 promotion beyond the tested range (G1-e), DScript promotion proof (XU4), live-replay equivalence vs a donor run (XU3 — no donor run), and generation-owned `GenerateMapRandKey`/saved-map key bytes (G1-h / XU1/XU2).
- P0-7 remains **open** until the **full** series and all restart/seed-change checks are zero-mismatch. Even then, `parity.status=UNVERIFIED`; no donor GPU A/B frame exists; no parity claim.

---

## 8. Hard-fail matrix — gaps that may NEVER be substituted

| Gap → / Forbidden substitute ↓ | S/G split unknown | Draw counts unknown | uniqrnd/frnd order | round() / key0 edge | RNG parity |
|---|---|---|---|---|---|
| Merge S and G draws into one stream, or route a G site through `sim_rng` | ✗ | — | — | — | ✗ |
| Snapshot a G value into a fixture / assert G values across restarts | ✗ | — | — | — | ✗ |
| Invent an `m+n`, `minesdensity`, or version-gated draw count | — | ✗ | — | — | ✗ |
| Draw `uniqrnd` after `frnd`, or treat stored `uniqrnd` as a draw | — | ✗ | ✗ | — | ✗ |
| `floor(x+0.5)` for donor `round()`, or claim donor behaviour for signed `key0` cases | — | — | — | ✗ | ✗ |
| Reintroduce `seed+si*1000003+ver*10007` per-stage derivation | ✗ | — | — | — | — |
| Rename/remove v5 save keys, bump save version, or wire `audio_rng` into sim | ✗ | — | — | — | — |
| Retune a threshold, delete a result, retry-until-green, or add a port fallback to force 0 mismatches | ✗ | ✗ | ✗ | ✗ | ✗ |

---

## 9. Status until the owner executes §2-§6 (explicit, non-negotiable)

- **P0-7 stays open** (`u_register_update.md §1`; `handoff_checklist.md §3` — this packet closes nothing by itself). `blocking_unverified` stays non-empty; six-condition chain remains 0/6; verdict remains **`RESULT IS NOT GOOD`**.
- The port keeps the single `sim_rng` S stream with all G-attributed sites still on it; `[U]-G1` labels stay; no threshold retuned; no second stream wired; no donor stream claim.
- `parity.status=UNVERIFIED`, `parity.claim=NONE`, `visual_parity_claim=false` throughout. Even after all series land green, this yields donor-text-pinned internal consistency only — **not** a donor observation, and no same-camera donor/port A/B frame.

## 10. Non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no harness/gate/runner job launched, no port capture compared by this worker. All donor readings are re-cited `[O]/[D]` from the pinned upstream reports; all unsettled items are `[U]` with the §4 experiments and §6 gates.
- **No stream or draw invented.** G values are count-only; the two seeding contexts are distinct; the `bits LE` table discrepancy is disclosed, not resolved by guessing; generation-owned and signed-`key0` items stay `[U]`.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md`. No code/asset/config/shader/Godot/git change; no donor file opened for write; no Craft Anything native call; no investigation memory written.

---

*End of PORT1TO1-RNG-OWNER-PROTOCOL.* Read-only; exactly one repository file written; no code/Godot/git/donor execution. No approximation, no parity claim. P0-7 stays open until the full owner-only series is zero-mismatch; `parity.status=UNVERIFIED`; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.
