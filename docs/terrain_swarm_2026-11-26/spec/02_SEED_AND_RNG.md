# 02 — Seed and RNG (from D02 + X03)

Source: `reports/D02_seed_rng.md` (4-pass decompile + raw-byte cross-check),
`reports/X03_dscript_corpus.md` (11 re-seed sites). **No donor parity claim.**

## 1. Key schema [O]

- Port "randkey1/2" is a misnomer: donor has **two 32-bit integers `randkey0`,
  `randkey1`** (`TMapSettingsGen`, map format `0x182640`). Installed via
  `SetRandomExtKey64(k0,k1)`, the **high word is `randkey0`, low word `randkey1`**.
  `GetRandomKey` returns `randkey1`, embedded in the generated map filename
  (`donewgame.inc:16,33-37`; evidence `ev_14126307…`).
- Key derivation function `GenerateMapRandKey` remains `[U]`.

## 2. Core RNG [O]/[D] — exact

32-bit LCG inside a 64-bit arithmetic wrapper, CODE VA `0x60f64c`–`0x60f696`
(file `0x20ea4c`–`0x20ea96`; identical constants in `editor.exe`, `config.exe`,
`modman.exe`):

```
s ← (s × 0xFC0D + 0x3C6EF35F) mod 2^32
RandomExt() = float32( int64(s) / 2^32 )   ; in [0,1) after first draw
```

Output divisor `2^32 = 4294967296.0` at VA `0x60f698` (`ev_6283059d…`).
64×64 multiply helper `0x406718`, 64-bit modulo helper `0x4067b8`.

**No `RandomInt` / `RandomFloat` engine API exists.** Registered DScript API
(`cossacks.exe:CODE+0x209a62…0x209b31`, `ev_1858bbfd…`, `ev_3526b7da…`):
`RandomExt(): Float`, `Random(): Float`, `GetRandomKey`, `SetRandomKey`,
`GetRandomExtKey64`, `SetRandomExtKey64`. Script wrappers:
`GetRandom(n) = floor(RandomExt*n)`,
`GetRandomRange(min,max) = min + floor(RandomExt*(max-min+1))`
(`dogenerate.inc:990-997`). Port's `RandomInt/RandomFloat` are inventions.

## 3. Three independent streams [O]

1. DScript-global state at `0x9048d4/d8`;
2. per-object generator RNGs (e.g. `sub_7281bc`, state `this+0x18/+0x1c`, 15
   callers in relief/terrain region `0x71e438`–`0x728190`);
3. separate Delphi `Random()` LCG (`seed = seed*0x8088405+1`, output
   `seed/2^32`, scaling `2^-32` at `0x8f206c`).

Three native setters `SetRandomExtKey64`, `SetMapGeneratorRandomKey`,
`SetGlobalMapGeneratorRandomKey` are called back-to-back in `donewgame.inc:33-35`
→ different instances.

## 4. Stage-scoped determinism [O]

`SetRandomKey(randkey1)` is re-issued before every generation stage — **11 sites**:
`D3:99, :146`, `D1:1100, :1161, :1177, :1213, :1538, :1616, :1772, :1909, :1927`
(X03), plus three `SetRandomExtKey64` resets in `generatemap.inc:216, :513, :774`.
Start selection consumes a **fixed number** of draws per player index
(`for j:=0 to i-1 do RandomExt`, `dogenerate.inc:1096-1103`). Reproducible replay
needs **call-for-call parity inside each stage**; stage reseeds isolate stages.

Specific fixed draws recorded: `foreststype := floor(RandomExt*3); foreststype := 0`
(`dogenerate.inc:0-11` — one consumed draw, neutralised result);
`relieftype := floor(RandomExt*5)` after `:1616` reseed (`:1612-1623`);
`minesdensity := floor(RandomExt*3)` occurs **before** the `:1616` reseed (`:1578-1595`).

## 5. No per-stage key derivation (from V01) [O]

There is **no donor key-derivation function** in the script tree: all 11
`SetRandomKey` re-seeds pass `gMap.settings.gen.randkey1` **verbatim**, and the
3 `SetRandomExtKey64` calls use `randkey0/1` verbatim (V01 P1/P2). A02's
`mix64(randkey1, randkey2, stable_hash(sid))` is a **PORT APPROXIMATION that
diverges** — the donor restarts the *same* stream at each stage, it does not
derive independent per-stage streams. The engine key→state/RandomExt internals
remain `[U]` (D02/X01).

## 6. Implementation consequence [D]

The fresh module must expose a **stage-scoped ledger that re-seeds the same LCG
from the original key** and consumes draws in donor order; the port's single
`game.rng` stream, inert `gen_rng` reseeds (P01 §3) and any mix64 derivation
cannot reproduce donor maps. Save-map key bytes and instance class identities
remain `[U]`. X21 is producing numeric vectors.

---
*Integrated by COORD from D02 + X03.*
