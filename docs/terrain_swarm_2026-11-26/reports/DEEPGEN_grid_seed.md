# DEEPGEN-3 — Grid size / seed derivation / callback order logic audit

Worker: DEEPGEN-3 (read-only). Scope: LOGIC-step audit only — no code/Godot/generation
executed, no donor binary executed, no repo file besides this one written.
Parity status: UNVERIFIED. No parity claim. No approximations. No invented values.
Chain: 0/6. RESULT IS NOT GOOD.

Donor law sources read: `spec/01_WORLD_DATA_MODEL.md` §§1-2, `spec/02_SEED_AND_RNG.md`
§§1-6, `spec/10_STAGE_ORDER.md` §1, `reports/D02_seed_rng.md` §§1-2 (partial),
`reports/X21_rng_vectors.md` (via port header cites only — full vectors NOT re-read,
stays [U] here), `reports/DEC_U_nb4.md` §§2-4, `reports/DEC_U_b3_callback_sweep.md`
§§2-4 (L3-L10, §3 census), `reports/DEC_U_gen_seed.md` (via port cites only — [U]).
Landed reports V01 / X03 corpus NOT fully re-read this ticket — every claim that
would need them is marked [U] below, never MATCHES.

Port sources read: `variant3d/scripts/terrain_donor_gen.gd` (esp. lines 457-529,
681-717, 816-931, 1152-1228, 1231-1261, 1264-1301, 1373-1394),
`variant3d/scripts/terrain_donor_inputs.gd` (esp. lines 454-531, 648-671, 697-727,
729-798), `variant3d/scripts/config.gd` lines 132-133, 538-539.

Label key: MATCHES = port logic textually implements the cited donor law;
DIVERGES = port logic textually contradicts it; [U] = could not verify here
(unread donor evidence, unread landed report, or live-value question).

## (a) randkey0=0 / randkey1=Random($7FFFFFFF) — telemetry only, NOT read by generation

Donor law:
- [D] (DEC_U_nb4 §2.1, bytes `ev_c0d732fb…/ev_e3d17104…/ev_dc243dd3…/ev_073af193…`):
  impl `0x6ac244` = `mov eax,0x7fffffff; call 0x403a0c; cdq; store(hi→randkey0,
  lo→randkey1)` ⇒ `randkey0=0` CONSTANT, `randkey1=Random($7FFFFFFF)` ONE draw, no
  map-name/settings input, `ret 8` (DEC_U_nb4.md:68-115).
- [O] seed consumption: `randkey0 := gMap.settings.gen.randkey0;
  randkey1 := gMap.settings.gen.randkey1` (`generatemap.inc:141-142, ev_51c638a0…`,
  spec/02 §1; D02 §2 row `ev_14126307…`); all 11 `SetRandomKey` + 3
  `SetRandomExtKey64` sites consume randkey1 verbatim, key0 discarded mod 2^32
  (spec/02 §§4-5; DEC_U_b3 §2 L10).
- [U] live Delphi state/source feeding that draw + runtime invocation timing
  (DEC_U_nb4 §4 U-SS/U-TIME; DEC_U_b3 §2 L1-L2, §3 census caveat).

Port:
- `terrain_donor_gen.gd:457-529` (`RANDKEY_DERIVATION_AUTHORITY`) records the
  formula, opcodes, slots (`+0x18/+0x1c`, `+0x108/+0x10c`), probes. Header comment
  at `:450-456` states NEVER read by generation. VERIFIED textually: no code path
  from that const into `_stage_begin` (`:1152-1197`), `_LCG.reseed_from_key*`
  (`:695-708`), or `generate()` (`:816-931`). MATCHES the "labelled only" requirement.
- `terrain_donor_gen.gd:856-859`: `generate()` copies caller `p.randkey0/1`
  verbatim into `_rng0/_rng1`; absent keys → PORT placeholder 0 with a
  `port_approximations` note. No `Random($7FFFFFFF)` call, no mix64, no QPC read
  anywhere in the module (grep: zero `Random(` draws outside `_LCG`). MATCHES
  "caller words stay verbatim; no seed invented".
- `terrain_donor_gen.gd:1164-1177`: `ext` and `key` reseeds both route to the
  shared `_rng`; `key` path calls `reseed_from_key(k1)` (key0 ignored except ledger
  at `:1180-1197`); `ext` path calls `reseed_from_key64(k0,k1)` where
  `:702-708` sets `s = k1 & LCG_U32` and keeps `key0` ledger-only (X21 §4.3).
  `_rng_delphi` is never reseeded by `_stage_begin` (`:652-653`, `:1155-1156`).
  MATCHES spec/02 §5 "no per-stage key derivation" + X21 key0-discard as coded.
- [U] whether the port's caller (`terrain_donor_inputs.gd:454-531`
  `_derive_seed`, or `main.gd`/`world3d.gd`) actually supplies donor-fresh
  `(0, Random($7FFFFFFF))` vs a stale/config word: `_derive_seed` prefers
  `gameplay.randkey0/1`, else `gameplay.random_seed`, else `Data.RANDOM_SEED`
  (`:459-531`); derivation label itself admits `[U] U5/P5`. Live-value closure is
  NOT verified here. The generation-side non-consumption of the authority const
  is MATCHES; the end-to-end seed freshness is [U].

## (b) Grid width/height resolution — requested grid kept; native size side-carried; 64→256 seam and 240² disagreement

Donor law:
- spec/01 §2 table [O]: allowed `W=H` ∈ {256, 320, 480, 640}; `W,H` live in the
  container, never `Data.MAP_W`; flat index `i = y*W + x`.
- spec/02 §5 + D2:329 branch: scaled vs equal-size start-dedup path depends on
  native mask size vs map width (port cites D2:329/419-435; donor text NOT re-read
  here — [U]).
- The "known 64→256 native-mask seam" and "240² disagreement" are ticket
  premises, NOT re-derived from donor bytes here: no 64/256 mask-size law was
  located in the spec/reports read, and spec/01 lists no 64 or 240 size. Both
  stay [U] as donor facts.

Port:
- `terrain_donor_gen.gd:861-876`: `wv = p.width (or p.size); hv = p.height`;
  fallback to container `data.w/data.h`; abort if still ≤ 0; `_set_size` →
  `configure_grid(wv,hv)` (`:1137-1142`); `_grid_w/_grid_h/_grid_n` set from the
  REQUESTED pair. No replacement by native size anywhere in `generate()`.
  MATCHES spec/01 §2 container-holding.
- `terrain_donor_inputs.gd:758-765`: `_apply_mask` writes `p["width"]=w`,
  `p["height"]=h` (requested, "never native mask size") and side-cars
  `p["mask_native_width/height"]=mw/mh`. `terrain_donor_gen.gd:888-889` stores
  them in `_mask_native_w/h`, consumed ONLY by the D2:329 scaled-branch test at
  `:1425` (`_mask_native_w > _grid_w`). MATCHES "native size informs a branch,
  never replaces the grid".
- `terrain_donor_inputs.gd:648-671`: mask pool prefers exact native-grid matches,
  else deterministic sorted asset index 0; the donor `floor(RandomExt*count)` pick
  is explicitly NOT done here — it is the generator's D2:190 inherited-stream
  draw (`terrain_donor_gen.gd:1381-1386`, `_enter_inherited_site` + `next_int`).
  The old FNV-hash pick is removed (`:658-666`). As coded this is internally
  consistent; donor-faithfulness of "sorted index 0 + generator draw" is [U]
  (needs X03/D2:190 text not re-read here).
- `terrain_donor_inputs.gd:697-727`: non-exact grids are resampled with donor-cited
  NEAREST `floor(x/W*srcW)` (`:705-717`, cites D2:409-411/541-542); bilinear only
  behind `mask_resample_mode == "bilinear"` comparison hook. Nearest-vs-donor
  sampler equivalence is [U] here (DEC_U_b3 §2 L11 honesty finding: shipped
  `generatemap.inc` on disk is a 9-line stub; `:130-200` body is carried corpus,
  not re-verified).
- DIVERGES / [U] — 240²: `config.gd:132-133` defaults `map_width/height_tiles=240`
  and `config.gd:538-539` writes them to `Data.MAP_W/H`. 240 is NOT in the
  spec/01 allowed set {256,320,480,640}. The generator honours whatever `w/h`
  it is given (no coercion — verified above), so a 240² request flows through
  unchanged; against donor size law that is a DIVERGENCE in allowed values
  (port default), with the donor consequence (what a 240² donor map would even
  mean) [U]. `terrain_donor_gen.gd:1266` (`mapsize = p.mapsize, default 3 if
  _grid_w==256 else 2`) further bakes a 256-special case with no donor cite
  visible at the use site — [U].
- [U] — 64→256 seam: no port line replaces a 64 request with 256 (verified
  absent in `generate()`/`_set_size`/`_apply_mask`); whether the donor does such
  a replacement at load/generate time was not found in the sources read — [U].
  No nearest-resampling hidden replacement occurs: resample output is checked at
  `terrain_donor_inputs.gd:753-756` (`mb.size() != w*h` → skip, labelled [U]).

## (c) Stage call order against donor

Donor law (spec/10 §1 [O], 12 items): init/seed (D3:99,:146) → clear → base tiled
patterns → settings branch → GenerateMap (D2) → shore exclusion → starts+border →
relief → forest/stone/decor → units+scale → FillOwnerMap+border objects → finalize.

Port (`terrain_donor_gen.gd:892-905`, inside `generate()` after `_resolve_settings`):
`_stage_init` → `_stage_clear` → `_stage_base_tiles` → `_stage_settings` →
`_stage_generate_map` → `_stage_shore_exclusion` → `_stage_starts` →
`_stage_relief` → `_stage_forest_stone` → `_stage_forest_borders` →
`_stage_units_scale` → `_stage_owner_map` → `_stage_finalize`, then `_close_ledger`
and optional `d3_wrapper_hook` (`:909-915`, engine-side [U], default skipped).
MATCHES the 12-item donor order as coded, with two labelled caveats that do NOT
change the order verdict: `_stage_forest_borders` is a NULL stub (P-PLACE-11/N17,
`:902` comment) and `sow_field` (`:1054-1081`) is deliberately NOT in the pipeline
(mill-trigger effect). Internal reseed/site sequence MATCHES the cited donor
sites: D3:99/:146 (`:1292-1294`), D1:1538 after base tiles (`:1352`, comment cites
X03:284), D2:190 inherited draw before D2:216 ext-reseed (`:1374-1388`), D2:216
(`:1388`), D2:513 (`:1394`), D2:774 (downstream of read window — cited in ledger
tables, not re-verified line-by-line here, so the D2:774 position itself is [U]
beyond the ledger claim). Per-stage draw accounting via `_mark_site` (`:1254-1261`)
MATCHES spec/02 §6 ledger consequence as structure; numeric draw parity is [U].

## (d) Callback registration

Donor law: 11 `SetRandomKey` + 3 `SetRandomExtKey64` registrations are the
callback surface (spec/02 §4; DEC_U_b3 §2 L9: VM-dispatched via `sub_608238`,
0 static xrefs = dispatch, not absence).

Port:
- `terrain_donor_gen.gd:878-879`: every stream's `on_draw` is wired to
  `Callable(self, "_record_draw")` at generate() entry. `_record_draw`
  (`:1231-1241`) appends `{i, stream, s, r}` to the current stage ledger, capped
  at 4096 samples (`samples_truncated` flag); `_tel`/`stats()` (`:935-946`)
  duplicates ledgers out and never feeds them back into generation/mesh/tiles.
  MATCHES "registration is telemetry-only" as coded.
- Generation RNG callbacks DIVERGE from a 3-stream donor picture by design and
  say so: `_stage_begin` ext-path comment (`:1164-1170`) routes `SetRandomExtKey64`
  through the SAME RandomExt generator (old `map_generator` stream now idle
  diagnostic, `stats()` `:948-951`). Whether that matches donor instance
  identities is [U] (spec/02 §3 says distinct instances; donor class identities
  `[I]/[U]` per port line `:746`). Structure MATCHES the port's stated contract;
  donor-instance parity is [U].
- `main.gd`/`world3d.gd` callback wiring was NOT traced to a call site in this
  ticket (grep shows `Data.MAP_W/H`, snapshot and camera uses, but no
  `C3TerrainDonorGen.generate()` invocation line was confirmed). End-to-end
  registration order from UI to generator is therefore [U].

## Verdict table

| # | Check | Verdict | Port file:line | Donor source |
|---|---|---|---|---|
| 1 | randkey formula recorded, labelled only, never read by generation | MATCHES | `terrain_donor_gen.gd:457-529` (authority) + `:450-456` (never-read guard); non-use verified at `:1152-1197`, `:695-708`, `:816-931` | DEC_U_nb4 §2.1 (`ev_e3d17104…/ev_dc243dd3…/ev_073af193…`); DEC_U_b3 §2 L3 |
| 2 | caller randkey0/1 verbatim, no invented seed | MATCHES | `terrain_donor_gen.gd:856-859` | spec/02 §1 (`generatemap.inc:141-142`); DEC_U_nb4 §4 |
| 3 | key0 discarded, all 11+3 reseeds consume key1; Delphi stream untouched | MATCHES (as coded) | `terrain_donor_gen.gd:1164-1177`, `:702-708`, `:652-653` | spec/02 §§4-5; X21 §4.3 (via port cite — vectors not re-read, [U] on numeric proof) |
| 4 | requested grid kept; native size never replaces it | MATCHES | `terrain_donor_gen.gd:861-876`, `:1137-1142`; `terrain_donor_inputs.gd:758-765`, `:888-889`, `:1425` | spec/01 §2 |
| 5 | nearest resampling when sizes differ; no silent native substitution | MATCHES (as coded) / donor-sampler proof [U] | `terrain_donor_inputs.gd:697-727`, `:753-756` | port-cited D2:409-411/541-542; donor text [U] per DEC_U_b3 §2 L11 |
| 6 | 240² default vs donor allowed sizes | DIVERGES (port default) / consequence [U] | `config.gd:132-133`, `:538-539`; `terrain_donor_gen.gd:1266` | spec/01 §2 {256,320,480,640} |
| 7 | 64→256 silent replacement | No such replacement in port (verified absent); donor side [U] | `terrain_donor_gen.gd:861-876`; `terrain_donor_inputs.gd:729-798` | [U] — no 64/256 law located in sources read |
| 8 | 12-stage call order | MATCHES (with NULL forest-border stub + off-pipeline sow_field, both labelled) | `terrain_donor_gen.gd:892-915` | spec/10 §1 |
| 9 | reseed/site sub-order (D3:99/:146, D1:1538, D2:190→216→513) | MATCHES as cited; D2:774 position [U] | `terrain_donor_gen.gd:1291-1301`, `:1352`, `:1374-1394` | spec/02 §4; X03 (via port cites — corpus not re-read) |
| 10 | draw/telemetry callback registration feeds ledger only | MATCHES | `terrain_donor_gen.gd:878-879`, `:1231-1261`, `:935-946` | spec/02 §6 (ledger consequence) |
| 11 | live seed freshness / invocation timing / per-site draw counts / UI→generator wiring | [U] | `terrain_donor_inputs.gd:454-531`; probes at `terrain_donor_gen.gd:518-522`, `:1032-1044` | DEC_U_nb4 §4; DEC_U_b3 §§3-4, §7 |

Chain: 0/6 CLOSED. Blocking [U] non-empty (live values, timing, sampler proof,
size-law consequence, UI wiring). RESULT IS NOT GOOD. Parity: UNVERIFIED; no
parity claim of any kind.
