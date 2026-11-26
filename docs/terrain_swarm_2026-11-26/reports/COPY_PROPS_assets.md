---
id: COPY-PROPS
ticket: "TERRAIN-VISUAL-WAVE-2026-11-26 / COPY-PROPS — adopt validated compact prop bundle into assets"
worker: "COPY-PROPS (worker subagent, donor-terrain VISUAL WAVE; reports to COORD)"
wave: VISUAL
date: 2026-11-26
status: DELIVERED__ASSETS_ONLY__ONE_REPORT_ONLY__NO_CODE__NO_GODOT__NO_RUNNER__NO_GIT__NO_DONOR_WRITE
owner_file: docs/terrain_swarm_2026-11-26/reports/COPY_PROPS_assets.md
labels: [O, D, I, U]
parity_claim: false
parity_guard: "No donor binary was executed, no donor GPU frame was read and no donor file was written. Every figure below is a byte/hash/parse observation on the prototype JSON and its byte-identical copy. NO DONOR PARITY CLAIM."
scope: "Read first: reports/PERF_FEED_preindex.md and %TEMP%/opencode/props_preindex/. Write boundary: variant3d/assets/terrain_new/props/** plus this report only. No .gd/.tscn/.json outside props/, no shader, config, manifest file, Godot process, runner job, git state or donor file touched. Donor READ ONLY."
source_snapshot: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\props_preindex\\out\\ (props_index.json + families/*.json), validated by PERF-FEED"
destination: "variant3d/assets/terrain_new/props/"
---

# COPY-PROPS — byte-exact adoption of PERF-FEED's compact prop bundle

## 0. Executive summary

1. **[O]** Copied the validated compact per-family prop bundle from the PERF-FEED
   prototype into `variant3d/assets/terrain_new/props/`, preserving directory
   structure (`props_index.json` + `families/*.json`) and byte content.
2. **[O]** Destination contains **78 files / 11,015,153 B** — 1 index
   (**49,371 B**) + **77 family files** (**10,965,782 B**). Exactly matches the
   prototype snapshot and the PERF-FEED report.
3. **[O]** Recount on the copied data: **39,780 records**, **235 distinct
   `BaseName`**, **0 schema violations**, **0 records asserting parity**.
   `props_index.json["visual_parity_claim"] == false`; the 77 family files carry
   only `{family, sections}` and contain **no** `visual_parity_claim` key, so no
   JSON in the bundle asserts parity.
4. **[O]** All 78 destination files are **byte-identical** to the prototype:
   size + SHA-256 agreed in a Python pre/post comparison and in an independent
   PowerShell `Get-FileHash` cross-check (0 mismatches).
5. **[D]** No repo manifest file was created — the prototype snapshot contains
   no manifest to inherit, and the SHA-256 manifest is recorded **in this report
   only** (§5), per the task constraint.
6. **[I]/[U]** This is an asset placement only. No consumer/I09 change, no Godot
   run and no donor A/B was performed. **NO DONOR PARITY CLAIM.**

---

## 1. Write boundary and provenance

- **Written:** `variant3d/assets/terrain_new/props/` (78 JSON files) and this
  report. Nothing else.
- **Not written:** any `.gd`, `.tscn`, `.json` outside `props/`, any shader,
  config, `manifest.json`, Godot process state, runner/gate artefact or git
  state.
- **Donor:** read nothing from the donor tree for this task; no donor binary or
  raw file copied. The source of the copy is the **derived JSON snapshot** under
  `%TEMP%\opencode\props_preindex\out\`, not a donor file.
- **[O]** Destination `props/` did not exist before the copy; the prototype
  `out/` held exactly two top-level entries (`families/`, `props_index.json`).
- Labels: **[O]** literal byte/count/hash observation; **[D]** deterministic
  consequence; **[I]** inference; **[U]** unverified without a Godot/owner run.

---

## 2. Source snapshot (read-only, as validated by PERF-FEED)

| Metric | Value |
|---|---:|
| Prototype `out/` file count | 78 |
| Prototype `out/` total bytes | 11,015,153 |
| `props_index.json` | 49,371 B |
| `families/*.json` (77 files) | 10,965,782 B |
| Declared `record_count` | 39,780 |
| Declared `distinct_basenames` | 235 |
| Declared `family_count` / `section_count` | 77 / 665 |
| `excluded_inline_records` | 3 |
| `files` / `families` / `section_family` lengths | 665 / 77 / 665 |
| `schema` | `terrain_new/props_preindex/v1` |
| `source_sha256` (metadata anchor, not a copied file) | `a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581` |
| `source_bytes` (metadata anchor) | 55,784,815 |

**[O]** `visual_parity_claim` is `false` in `props_index.json`; every family
file's top-level key set is exactly `{family, sections}` (no parity key, no
`value`/`label`/`literal`/`line` record wrappers).

---

## 3. Copy procedure

1. Enumerated every file under prototype `out/` (78 paths, recursive).
2. For each relative path, created the matching directory under
   `variant3d/assets/terrain_new/props/` and copied bytes verbatim
   (`shutil.copyfileobj`, 1 MiB chunks — no re-serialization, no JSON rewrite).
3. Re-walked both trees and compared, per path, **byte length and SHA-256**;
   asserted identical path sets.
4. Re-parsed the **destination** JSON independently and re-derived all counts,
   schema checks and the parity guard (§4, pass 4).
5. Generated the SHA-256 manifest (§5) from the **destination** hashes.

**[D]** No file content is transformed: the copy is a pure byte transfer, so
PERF-FEED's determinism and round-trip results carry over unchanged.

---

## 4. Multi-pass verification (counts and hashes)

Five independent passes; no result was accepted from a single reading.

| Pass | Tool / target | Checks | Result |
|---:|---|---|---|
| 1 | Python 3.14.3 / prototype `out/` | file count 78; total 11,015,153 B; index 49,371 B; family bytes 10,965,782 B; parse index contract; walk all records: key sets `{BaseName,Position,Direction,Up,Scaling}` and `{X,Y,Z,W}`, `BaseName` non-empty str, finite components, no wrapper keys; count records/BaseNames; parity | 78 / 11,015,153 / 49,371 / 10,965,782; **39,780 records; 235 BaseNames; 0 violations**; index parity `false`, families no parity key |
| 2 | PowerShell 5.1 `Get-ChildItem` / prototype `out/` | independent file count + byte sum | **78 files / 11,015,153 B** |
| 3 | Python / prototype → destination | per-path byte length + SHA-256 equality, path-set equality, copy | **78/78 paths identical; 0 size/hash mismatches** |
| 4 | Python / destination (copied data) | parse index contract; recount records/BaseNames; schema violations; `visual_parity_claim is True` scan | **39,780 / 235 / 0 violations / 0 parity-true** |
| 5 | PowerShell `Get-FileHash -Algorithm SHA256` / destination | recompute all 78 hashes and compare to Python manifest; independent file count + byte sum | **0/78 hash mismatches; 78 files / 11,015,153 B** |

**[O]** Pass 2's JSON depth check was not available (Windows PowerShell 5.1
`ConvertFrom-Json` has no `-Depth`); its role was the independent file/byte
census, which succeeded. All JSON parsing/counting was done in Python (passes
1, 3, 4); all independent hashing in PowerShell (pass 5).

**Stop-condition checks:** 78 = 78 = 78; 11,015,153 = 11,015,153 = 11,015,153;
39,780 = 39,780; 235 = 235; violations 0 = 0; hash mismatches 0 = 0.
No anomaly observed.

---

## 5. SHA-256 manifest (78 files)

**[O]** Computed on the destination files in `variant3d/assets/terrain_new/props/`.
Paths are relative to that directory. This table **is** the manifest; no
manifest file was added to the repository.

| # | Path (relative to props/) | Bytes | SHA-256 |
|---:|---|---:|---|
| 1 | `families/b_frt_b_p.json` | 45545 | `a71131c4b309f1295ff9b7718928de045c30e9c15af25b06ddcc568f9405b17d` |
| 2 | `families/b_str.json` | 22983 | `5e780b168e3fefe2aef4e376a644a13b4644862f728dbe49e3ade09d5afdf1b7` |
| 3 | `families/big_hill.json` | 34193 | `3196ec3d4bb84225131776e7f1f3aa3b19b4784a6420f2bf4790fbd7ca12b90b` |
| 4 | `families/d_frt_big.json` | 218337 | `29df1c21ed60b1bdc3758c0c4be848a9cfab0fbf6e8481dd80c51b5abc69f77c` |
| 5 | `families/d_frt_mid.json` | 116647 | `c89bd0dceacb9f3cb53e3a6bce5cfa18462c4218f1dc425de1af25e5a2393517` |
| 6 | `families/d_frt_pinedry_big.json` | 134520 | `0420512b1127425c96e55e5d2cd3b8c420d43c9a3f564d33dd8de498256ba700` |
| 7 | `families/d_frt_small.json` | 58626 | `674cacb97c421157c728f6fb7c7e9227592d848d5a4c5b9bb42125ce3cd16e98` |
| 8 | `families/d_frt_spr_big.json` | 106702 | `62a51dcfa54ca95e422c6b84567186b3a843ff10c9ce10e43b983eebb499b1ea` |
| 9 | `families/d_frt_spr_mid.json` | 100025 | `988162cfa4bef613982b863cd77869937126784052e62f29c4bd967553ddaef1` |
| 10 | `families/d_plt.json` | 363552 | `aa49e9f3c0785c3508ea4bf75ccc4bb2b8f8b2662bbc62ac30b17bce60814553` |
| 11 | `families/d_stn.json` | 54647 | `aacbb09d92149434d99965ea556d407d927cea94a52bbb76f1ef2c3b3eef5abf` |
| 12 | `families/dcr.json` | 13808 | `4c33d8b914e578cf4edcd69d296ab62a9d003028adfb1e9c281b780f9ebfb3a6` |
| 13 | `families/desert_frt_big.json` | 116665 | `545cf500739103a58ae8db773be0cbb468e6c49fdfc60c7220b7b63a9cf7c430` |
| 14 | `families/desert_frt_m.json` | 149418 | `3f03246b37a78990eb921414929adf3932ad7c819e786e41d08b89ec623e680c` |
| 15 | `families/desert_frt_s.json` | 97727 | `2d86f62774b901e40ba307c534e445f16ffef7e0b52c17d216621aff6aee6b5a` |
| 16 | `families/desert_frt_un.json` | 159335 | `ff8c8cda761c402f7f235f440c7bdfd5dc68e0aede20997f368f9e86457eeca6` |
| 17 | `families/desert_lake.json` | 140897 | `f9ecf41696974f0ebd1efe2802b8365951691f2e9a80315811d3164e23b90d82` |
| 18 | `families/desert_mnc_1_a.json` | 2939 | `78c8f25407717516b533b402b4ef979e2c77376b4eebd11c01d2f525a90c4741` |
| 19 | `families/desert_mnc_2_a.json` | 4771 | `08a55a832375853b54d67b223b0b8ee79ac8c3a86bce0bc1ff06bdaca49ce7c5` |
| 20 | `families/desert_mnc_3_a.json` | 3508 | `9c7db83d6c1e7f608cfa9c7b0eae05bde381663e1c3c9640110116f3a3452c08` |
| 21 | `families/desert_mng_1_a.json` | 2934 | `66ffc11bbd4062251cb6301b5f273f8c3991886d8e686bb78874c164fe10cae5` |
| 22 | `families/desert_mng_2_a.json` | 3200 | `2a3f9f750596f56eaaaa39d833ba2c08bf3807e59697ed0d5d733b74e292e90a` |
| 23 | `families/desert_mng_3_a.json` | 2982 | `9c02961fe2555b325bc3989ba8a2b85b938b44d20473d6890c72ad79e782d9dd` |
| 24 | `families/desert_mni_1_a.json` | 2753 | `cfde8392bf6c1b94492dbdbcbceb861158582c013843197c5f23c80fcad7ed00` |
| 25 | `families/desert_mni_2_a.json` | 2965 | `7049994a94a3b0000adc4fae9992a22e48195b9dc2b95f4c1fd303ed9687740a` |
| 26 | `families/desert_mni_3_a.json` | 4033 | `89c4169ddba143dff6293e0850326c0218331da25ecc50aabeecc3f7d2b04302` |
| 27 | `families/desert_mnt.json` | 96529 | `99f50c3fcefaba56260e3b45ecca2c0040cbc0934b6d45083a0df5816a5250ac` |
| 28 | `families/desert_plain.json` | 245880 | `8be5edc766ad25ac1e5e7f4cda9b39cb96898e4ff1c1fac2367239016c56acd3` |
| 29 | `families/desert_plt.json` | 449272 | `900d58571b9b48696dc14b059bf5f37ea34b1ab84b82c3f881ad46ef4de6dac2` |
| 30 | `families/desert_stn.json` | 56393 | `c2cc21323a4877c85c80221676e8e6ef67812cdc30efc7056fdb26770b3b35ba` |
| 31 | `families/e_frt_big.json` | 408991 | `0a6d89bcc0cd3b11276b2581b201af85997ccf726578d2a1bf274673a60f852a` |
| 32 | `families/e_frt_mid.json` | 195298 | `1bfe90fec4a479bcd24f31abf8c0901d499c298d17e966543d7af2793c891dd2` |
| 33 | `families/f1_from_big.json` | 22563 | `3672ba3d7846fd10e2dc4245131a8ba21b0e25e0aab20b95d9998472643e9c36` |
| 34 | `families/f_plt_big.json` | 322122 | `0fb9c188627deeca5eb0e2e4c3d883e48f6a0b2d3784cc46747a9789b7ecaa1a` |
| 35 | `families/f_plt_mid.json` | 112905 | `0c1145f5bfae8141799e6e5865cdff92e80cf035764630a1b03b26260c412e19` |
| 36 | `families/fb.json` | 68016 | `40b2a4d2de496790362265f698adc94ae63b0ba9d3f812a4ffc4bb9de1aa3980` |
| 37 | `families/frt_b_p.json` | 115962 | `b09e8c45e4362c10260a5f5e138098b2d115ce4716ef2cdef274de85e8892d89` |
| 38 | `families/frt_m_p.json` | 47513 | `860a382bdbe22914a159a3712ea020d81cc31aa4227654af7056be4a7500aa07` |
| 39 | `families/frt_s_p.json` | 13482 | `4548733d4bffac85fd9b843e79e89d97d527bd8c2466f927e9826e27ce998d44` |
| 40 | `families/g_frt_big.json` | 80666 | `ea635d4b48159299dc60dbdfb48bf0f0fe7d882f30d849c33b6782b9e81134f0` |
| 41 | `families/g_frt_mid.json` | 63223 | `c3d3fe62ea866db359e8cbc3511b325bda261916ea69e45f799a67cddfc35778` |
| 42 | `families/g_frt_small.json` | 47421 | `322ff70848609275a9df7a7c849e04f57908529bead69845f3c3ff31ff18b96e` |
| 43 | `families/g_hil.json` | 245163 | `6e98f8e123ea327597ae78522bd7f84cd590661ed71fcb8e304f6342988088fc` |
| 44 | `families/g_mnt.json` | 195632 | `0ee76b797acb9ca21c7a047d05f4d46de6f16c06bc9879158c1490c4dfafc6fb` |
| 45 | `families/gift.json` | 9382 | `fed9f8909ad714549ae675fb48c8dddeffec94814465b83f00a7247eab73f38e` |
| 46 | `families/hil.json` | 54869 | `20470313aa38b7e9b2efe81a907a03aeb68278cf04529178cec6c638550bd5dc` |
| 47 | `families/i_mnt_big.json` | 400819 | `aea4d5377db1be3fc7ec116588ee830ba11a5c899fff0c1371cc22e67e6cc5b2` |
| 48 | `families/i_mnt_long.json` | 330313 | `ebf6a35aa48420bf9b0e7533054370d654960d7c3ed0e8fb3e70b878630a493a` |
| 49 | `families/j_big_plt.json` | 645343 | `1e1eaa28cd6cfcaf75b474f93299460d9316a17a4f29cba6c13ff38a554bee78` |
| 50 | `families/k_lake.json` | 63619 | `4ae9762e937cf5649ab2db51604ad8ebffefb86f85d954d8f047bda995ad6dd5` |
| 51 | `families/k_plain.json` | 436216 | `2685a20932070e63408b30f7e03b4e5056ca9ba39b6ec462e1626710b683652b` |
| 52 | `families/k_plain_mid.json` | 231323 | `8e777f7359a9b3e3046449abff2c22cb67e2e88c9ff117198a88bdccf9209fd0` |
| 53 | `families/k_pump.json` | 22094 | `6346335bf92733eb9dcb8cb3f214ce1affba1aa3653e6f89556558f3dfd0f106` |
| 54 | `families/k_ravine.json` | 580302 | `6a1810fb7b760a5c8d550798b948afaddbc17e9175e949ae8ad7d6ebff010491` |
| 55 | `families/k_ravine_big.json` | 70853 | `764422a285e8a5e312fcd5ac7e4d54a79b18c4951a84199e154e9026e0e94b14` |
| 56 | `families/k_ravine_big_stone.json` | 778872 | `a45bcdccd8adb1ce6781000febf240acbc2adc3d672ae5a05139c5af231d2a54` |
| 57 | `families/k_rock.json` | 88675 | `0b9cbd3541ae7806abe26d71204790f3cba6ea191b9b97fc3bd705a8a2eca6b8` |
| 58 | `families/k_small_plain.json` | 111081 | `90031525e33f3ad216f6d08021f2eeac2c60a5cf5b31df44985d206b05d8ad9d` |
| 59 | `families/k_swamp.json` | 116360 | `666a66b90e097fd0f94fbbd18df1b735272f57c570dd9b22b63724868a0819bd` |
| 60 | `families/l_lake_big.json` | 205711 | `f3443cd97d7aeb14e1a8f85a650a64d23139b42b5602711a35074bbe094530b7` |
| 61 | `families/l_lake_small.json` | 285671 | `fe9e6f46d34055b699ab1b0350cd7078feebe0dd27b6e29924a18dabb5e9ab01` |
| 62 | `families/m_swamp.json` | 239194 | `a4ee86a44b8e36587cb0797cdf24c6db5b60090bff57b631b8781df56429d056` |
| 63 | `families/m_swamp_12_old.json` | 9834 | `0b361e8cc793ce753548f99db7113d6b29215e0513928b2de2a7f59edf489107` |
| 64 | `families/m_swamp_small.json` | 56908 | `c5cd0ccfcbeb17e6d44bb8d14dfd37050d10e827aa0a81578c80072b947b86a5` |
| 65 | `families/mnc.json` | 18750 | `d80ae8f024746ec60071100c50afb4e09e089e02eb586396d6c8b77e277c9f35` |
| 66 | `families/mng.json` | 20068 | `261de5a7b9f1844a9917284b7a436ea6caff56c785fef50d7ed709677104b8ee` |
| 67 | `families/mni.json` | 18168 | `d488086a4cc07aa22cca42bbe6a080b7d578d3c56e3122a6e2d6412091e53b85` |
| 68 | `families/n_desert_frt_big.json` | 305108 | `f0ed521a5360378a49391c51b89dc493a1c3fb579dfeacbbeb3793cd4290c2f2` |
| 69 | `families/n_desert_frt_m.json` | 219798 | `0f7a2bcd377b2e3aafb885f78a67b9c1609c922392917611735e2c38f35c2490` |
| 70 | `families/n_desert_frt_s.json` | 132887 | `8296c987a38f6f90be8c502ced2f8c9ae475ae081fca8c5d07a1cef40b57fab5` |
| 71 | `families/n_small_frt.json` | 79848 | `bae3418bce07f8f096443beac92dfb33e627e1f61ae104fbdd05dc2cf2fc10c0` |
| 72 | `families/n_small_frt_lite.json` | 44113 | `8d6fdc9e150d93f87369645677473a311b7e1b63c4940accfa6fa5b22b0150a0` |
| 73 | `families/new_year.json` | 70363 | `753c14a79787563f96b63be11308b535d0dd6be7e337d1244c5a1cabfe408bc7` |
| 74 | `families/plt.json` | 317043 | `94b490728d799a72dc14f049ef083e1f706f9c07170e34269e169d914e7b9e64` |
| 75 | `families/plt4_fixed.json` | 80817 | `f3c0ffef4c4d8dba0fc396d04952ccbbbb9ef15c2c89d0c4bbb03c554392d79f` |
| 76 | `families/str.json` | 64987 | `15d7b1004059c384e7a7c79b09e8b050e1a06bdefe9f356d0dcacd4b01257736` |
| 77 | `families/str_new.json` | 105650 | `760b2b6e30877705248c6b38f04674a1fa6abd58d23b08db2b5a93d50b007ef9` |
| 78 | `props_index.json` | 49371 | `29a7b898b949e93ecf4129483dc46c6ccfb1377430d25f2f64cb3fd931b37e5f` |

**Sum check [O]:** 77 family bytes = 10,965,782; + index 49,371 = **11,015,153**.

---

## 6. Parity guard and open items

- **[D]** `visual_parity_claim` is `false` in `props_index.json` and absent in
  all 77 family files; the copied bundle makes **no donor parity assertion**.
- **[U]** No consumer change was made. W07 §7.1–§7.4 (stamp Object acceptance,
  `BaseName` unwrap, full `Scaling`/`Position.Y`, provenance gating) and I03's
  bundle reader remain required before `props_total > 0`.
- **[U]** The 3-record inline exclusion (`fb_6/firsmall1`,
  `fb_11/pinebroken2.2`, `fb_33/plantain`) is inherited unchanged from
  PERF-FEED. COORD/I03 still own the 39,780-vs-39,783 policy decision (see
  PERF-FEED §7 item 3); this copy does not change it.
- **[U]** Case-sensitive export / packed-PCK access and Godot parse timing were
  not tested. No runner/gate job and no Godot process was invoked.
- **[D]** No donor binary was executed, no donor GPU frame was read and no donor
  file was written. All conclusions are port-internal.

---

## 7. Handoff to COORD

Asset side is placed and verified byte-for-byte. Awaiting COORD/I03 decision on
adoption (PERF-FEED §7) and the inline-record policy; then I03 implements the
reader and an owner-run A/B validates runtime. Until then, leave the legacy feed
path unchanged. **NO DONOR PARITY CLAIM.**

*End of COPY-PROPS. One report + 78 asset files written; no code, Godot, runner,
git or donor edits.*
