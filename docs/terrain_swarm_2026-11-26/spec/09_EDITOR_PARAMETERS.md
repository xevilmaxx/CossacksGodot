# 09 — Generation config constants (from F03)

Source: `reports/F03_gen_config.md`. All values `[O]` from donor text bytes;
meaning `[I]` where no consumer was found. **No donor parity claim.** F03 hashed
all seven files and re-parsed from donor bytes rather than trusting prior counts.

## 1. Inventory [O]

| Donor file | Bytes | Lines | SHA-256 (prefix) | Structure |
|---|---:|---:|---|---|
| `data/gen/globalparams.cfg` | 537 | 22 | 15a8dc64… | 1 section, **19 flat keys** (`globalparams.cfg:2-20`; `:21` = `section.end`, `:22` empty) |
| `data/gen/localparams.cfg` | 508 | 20 | 8d174830… | `LocalTerrainParams` → 1 record, 13 keys |
| `data/gen/mapcover.cfg` | 1,196 | 40 | ff0a7bf4… | 1 climatic zone / 1 height zone / 1 tile; all four seasonal tile names **empty** |
| `data/gen/tilesmooth.cfg` | 2,796 | 129 | 1753533e… | 8 sections × 3–4 plain tile names = **30 `TileName` entries, no probabilities** |
| `data/gen/tilesmooth_scripts.cfg` | 64,017 | 1,863 | b82c8884… | real weighted table: **22 chains, 130 groups (118 active), 310 entries (282 active), 86 distinct names, ΣProb=174.0168** |
| `data/game/var/generator.cfg` | 70,074 | 2,367 | f8a5cd2e… | 6 base + 9 DLC5 mask types; 64 families, 493 `Pattern`/`Freq` pairs |
| `data/game/var/startingsettings.cfg` | 116,920 | 3,424 | 17d4aedd… | 19 start presets, 61 countries, 61 masks, 61 legends, 276 legend entries |

All CRLF. No other `generator.cfg`/`startingsettings.cfg` exists under `data/`
or `dlcs/`; DLC masks are referenced from `var/generator.cfg:29-66`.

[O] `globalparams.cfg` has exactly 19 active flat keys (`globalparams.cfg:2-20` inclusive); the "20" in `reports/F03_gen_config.md:36,48,459,801,878` is a summary-level error, not a missing key — confirmed by two independent V37 re-reads and X20's four passes (`reports/X20_cfg_decoder_prototype.md:104,204-214`), and no 20th key may be invented. *(V37 §2)*

## 2. `globalparams.cfg:1-22` — complete literal [O]

```
Size = 512                     :2
Sharpness = 0.6                :3
TileChangeFactor = 0.3         :4
FrequencyFactor = 0.000013     :5
CellsResolution = 1            :6
FailStandCount = 16            :7
DefaultMapSize = 256           :8
TileSmoothPasses = 6           :9
TileSmoothListFileName = .\data\gen\tilesmooth.cfg   :10
CastlesFileName = (empty)      :11
PatternPlayerName = pattern    :12
AddCastles = False             :18
CastlePlateauFactor = 5        :19
```
Full file verbatim in F03 §3.1.

## 3. `localparams.cfg:3-16` — one record [O]

`Name=0`, `HillPointsDensity=0.00008`, `MaxHillsHeight=0`,
`HillsHeightFactor=0.001`, `GlobalMixFactor=1`, `LocalMixFactor=1`,
`OffsetRadius=0`, `SmoothLevel=0.008`, `SmoothPasses=1`,
`SmoothFactor=0.15`, `MinHeight=0`, `MaxHeight=0.0001`,
`CriticalPointsDist=0`. Full verbatim in F03 §3.2.

## 4. Two real contradictions — preserve, do not "fix" [D]

- `globalparams.cfg:9` says `TileSmoothPasses = 6`, but the skirmish script
  hard-codes `SmoothTileMap(...,3)` (`smoothtiles.inc:237`).
- `globalparams.cfg:10` points at `tilesmooth.cfg`, but the script loads
  `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`).

Both are independently recorded in prior art (`TERRAIN_BLEND_DONOR_PLAN.md:105-127`,
`DEC_05_terrain_formats.md:451-456`). The fresh module must follow the **script**
behaviour for skirmish and keep the cfg literals as provenance.

## 5. Not in these files [O]

No seed, RNG algorithm, explicit height formula, water level or mine-count
constant exists in these configs. Those belong to D02, D05–D07, F01/F08, F09.
Do not mine these files for constants that are not there.

## 6. Implementation consequence [D]

`decode_donor_cfg.py` (I01) must emit `constants.json` with each literal plus
exact donor path:line, and `config_strings.json` for unparsed lines labelled
`[U]`. The editor-parameter mapping (D09) should map UI controls to these keys.

---
*Integrated by COORD from F03.*
